# LiveView Patterns

## Sources
- https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
- https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.JS.html
- https://hexdocs.pm/phoenix_live_view/bindings.html
- https://hexdocs.pm/phoenix_live_view/js-interop.html

---

## Callbacks

### mount/3

Entry point — called twice: once for static render, once on WebSocket connect.

```elixir
@callback mount(
  params :: unsigned_params() | :not_mounted_at_router,
  session :: map(),
  socket :: Socket.t()
) :: {:ok, Socket.t()} | {:ok, Socket.t(), keyword()}
```

```elixir
def mount(%{"id" => id}, _session, socket) do
  if connected?(socket), do: subscribe(id)
  {:ok, assign(socket, item: get_item!(id))}
end
```

Options (third element): `:temporary_assigns`, `:layout`.

### handle_params/3

Called after `mount` and on every `push_patch`. Use for URL-driven state.

```elixir
@callback handle_params(unsigned_params(), uri :: String.t(), Socket.t()) ::
  {:noreply, Socket.t()}
```

```elixir
def handle_params(%{"sort" => sort}, _uri, socket) do
  {:noreply, assign(socket, items: list_items(sort: sort))}
end
```

### handle_event/3

Handles client events from `phx-click`, `phx-submit`, etc.

```elixir
@callback handle_event(event :: binary(), unsigned_params(), Socket.t()) ::
  {:noreply, Socket.t()} | {:reply, map(), Socket.t()}
```

```elixir
def handle_event("delete", %{"id" => id}, socket) do
  {:ok, _} = delete_item(id)
  {:noreply, stream_delete(socket, :items, %{id: id})}
end
```

### handle_info/2

Receives messages from other processes (PubSub, timers, tasks).

```elixir
def handle_info({:item_created, item}, socket) do
  {:noreply, stream_insert(socket, :items, item, at: 0)}
end
```

### handle_async/3

Receives results from `start_async/3`.

```elixir
@callback handle_async(name :: term(), {:ok, term()} | {:exit, term()}, Socket.t()) ::
  {:noreply, Socket.t()}
```

---

## Navigation

| Function           | Effect                                      |
|--------------------|---------------------------------------------|
| `push_patch/2`     | Same LiveView, triggers `handle_params/3`   |
| `push_navigate/2`  | Different LiveView, same live session        |
| `redirect/2`       | Full page load, kills LiveView process      |

```elixir
{:noreply, push_patch(socket, to: ~p"/items?sort=name")}
{:noreply, push_navigate(socket, to: ~p"/other")}
{:noreply, redirect(socket, to: ~p"/external")}
```

---

## Streams

Server-stateless collections. Items freed after render.

### Setup

```elixir
def mount(_params, _session, socket) do
  {:ok, stream(socket, :items, list_items())}
end
```

### Template (required structure)

```heex
<div id="items" phx-update="stream">
  <div :for={{dom_id, item} <- @streams.items} id={dom_id}>
    {item.name}
  </div>
</div>
```

Parent needs `phx-update="stream"` + `id`. Each child needs `id={dom_id}`.

### Operations

```elixir
stream(socket, :items, items)                      # bulk insert
stream(socket, :items, items, reset: true)          # replace all
stream(socket, :items, [], reset: true)             # clear
stream_insert(socket, :items, item)                 # append (at: -1)
stream_insert(socket, :items, item, at: 0)          # prepend
stream_insert(socket, :items, item, at: 0, limit: -10)  # prepend, keep 10
stream_delete(socket, :items, item)                 # remove by struct
stream_delete_by_dom_id(socket, :items, dom_id)     # remove by DOM id
```

### stream_configure/3

Custom DOM id generation — call in `mount` before inserting.

```elixir
stream_configure(socket, :items, dom_id: &("item-#{&1.id}"))
```

### Empty state

```heex
<div id="items" phx-update="stream">
  <div id="items-empty" class="only:block hidden">No items yet.</div>
  <div :for={{dom_id, item} <- @streams.items} id={dom_id}>
    {item.name}
  </div>
</div>
```

---

## Async

### assign_async/3

High-level: auto-wraps in `AsyncResult`.

```elixir
def mount(%{"slug" => slug}, _, socket) do
  {:ok,
   socket
   |> assign_async(:org, fn -> {:ok, %{org: fetch_org!(slug)}} end)
   |> assign_async([:profile, :rank], fn ->
     {:ok, %{profile: fetch_profile(slug), rank: fetch_rank(slug)}}
   end)}
end
```

Template patterns:

```heex
<%!-- Manual check --%>
<div :if={@org.loading}>Loading...</div>
<div :if={org = @org.ok? && @org.result}>{org.name}</div>

<%!-- Component helper --%>
<.async_result :let={org} assign={@org}>
  <:loading>Loading...</:loading>
  <:failed :let={_failure}>Failed to load</:failed>
  {org.name}
</.async_result>
```

Options: `:supervisor`, `:reset` (boolean or key list).

### start_async/3

Low-level: you manage `AsyncResult` yourself via `handle_async/3`.

```elixir
def mount(%{"id" => id}, _, socket) do
  {:ok,
   socket
   |> assign(:org, AsyncResult.loading())
   |> start_async(:fetch_org, fn -> fetch_org!(id) end)}
end

def handle_async(:fetch_org, {:ok, org}, socket) do
  {:noreply, assign(socket, :org, AsyncResult.ok(socket.assigns.org, org))}
end

def handle_async(:fetch_org, {:exit, reason}, socket) do
  {:noreply, assign(socket, :org, AsyncResult.failed(socket.assigns.org, {:exit, reason}))}
end
```

---

## JS Commands (Phoenix.LiveView.JS)

Client-side commands — composable via pipe, no round-trip to server.

### Visibility

```elixir
JS.show(to: "#modal")
JS.hide(to: "#modal", transition: "fade-out")
JS.toggle(to: "#dropdown", in: "fade-in", out: "fade-out")
```

Options: `:to`, `:transition`, `:time` (ms, default 200), `:display`, `:blocking`.

### CSS classes

```elixir
JS.add_class("highlight", to: "#item")
JS.remove_class("highlight", to: "#item")
JS.toggle_class("active", to: "#item")
```

### Attributes

```elixir
JS.set_attribute({"aria-expanded", "true"}, to: "#dropdown")
JS.remove_attribute("aria-expanded", to: "#dropdown")
```

### Server events

```elixir
JS.push("delete", value: %{id: item.id})
JS.push("inc", target: @myself)                    # target component
JS.push("save", loading: "#save-btn")              # loading indicator
```

### Navigation

```elixir
JS.navigate("/path")
JS.patch("/path?sort=name")
JS.navigate("/path", replace: true)
```

### Focus

```elixir
JS.focus(to: "#search-input")
JS.focus_first(to: "#modal")
```

### Dispatch custom events

```elixir
JS.dispatch("my_app:clipboard", to: "#code", detail: %{text: "copied"})
```

### Transitions

```elixir
JS.transition("shake", to: "#item", time: 300)
```

### exec (run stored JS)

```elixir
<div id="modal" phx-remove={JS.hide(transition: "fade-out")}>...</div>
<button phx-click={JS.exec("phx-remove", to: "#modal")}>Close</button>
```

### Composing

```elixir
<button phx-click={
  JS.push("delete", value: %{id: @item.id})
  |> JS.hide(to: "#item-#{@item.id}", transition: "fade-out")
}>
  Delete
</button>
```

---

## Lifecycle Hooks

### on_mount/1

Runs before `mount` — for auth, shared assigns. Defined in a separate module.

```elixir
defmodule MyAppWeb.UserAuth do
  def on_mount(:require_auth, _params, session, socket) do
    case session["user_token"] do
      nil -> {:halt, redirect(socket, to: "/login")}
      token -> {:cont, assign(socket, current_user: get_user(token))}
    end
  end
end
```

```elixir
live_session :authenticated, on_mount: {MyAppWeb.UserAuth, :require_auth} do
  live "/dashboard", DashboardLive
end
```

### attach_hook/4

Dynamic hooks for `:handle_params`, `:handle_event`, `:handle_info`, `:handle_async`, `:after_render`.

```elixir
attach_hook(socket, :track, :handle_event, fn
  "tracked_event", params, socket -> {:cont, socket}
  _, _, socket -> {:cont, socket}
end)
```

Return `{:halt, socket}` or `{:cont, socket}`.

---

## Key Helpers

| Function           | Purpose                                |
|--------------------|----------------------------------------|
| `connected?/1`     | True on WebSocket (false on static render) |
| `put_flash/3`      | Flash messages (`:info`, `:error`)     |
| `cancel_async/3`   | Cancel in-flight async task            |
| `assign/2,3`       | Set assigns                            |
| `assign_new/3`     | Lazy assign (only if key missing)      |
