# HEEx Template Syntax

## Sources
- https://hexdocs.pm/phoenix_live_view/assigns-eex.html
- https://hexdocs.pm/phoenix_live_view/bindings.html
- https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html

---

## ~H sigil

Inline HEEx templates in Elixir modules:

```elixir
def render(assigns) do
  ~H"""
  <div>{@name}</div>
  """
end
```

Or use co-located `.html.heex` files (same name as module, auto-discovered).

---

## Interpolation

```heex
<%!-- Assign access --%>
{@name}
{@user.email}

<%!-- Expressions --%>
{String.upcase(@name)}
{length(@items)}

<%!-- In attributes --%>
<div class={@class}>
<div class={"card #{@extra_class}"}>
<input value={@form[:name].value} />
```

---

## Directives

### :if — conditional rendering

```heex
<div :if={@show}>Visible when @show is truthy</div>
<div :if={@items != []}>Has items</div>
<.icon :if={@icon} name={@icon} />
```

### :for — comprehension

```heex
<li :for={item <- @items}>{item.name}</li>

<%!-- With index --%>
<li :for={{item, idx} <- Enum.with_index(@items)}>
  {idx + 1}. {item.name}
</li>

<%!-- With pattern matching --%>
<div :for={{dom_id, item} <- @streams.items} id={dom_id}>
  {item.name}
</div>
```

### :key — change tracking optimization

```heex
<div :for={item <- @items} :key={item.id}>{item.name}</div>
```

### :let — receive values from slots/components

```heex
<.form :let={f} for={@form}>
  <input name={f[:name].name} value={f[:name].value} />
</.form>

<.table rows={@users}>
  <:col :let={user} label="Name">{user.name}</:col>
</.table>
```

---

## Component calls

### Local function component (same module or imported)

```heex
<.button type="submit">Save</.button>
<.input field={@form[:name]} label="Name" />
```

### Remote function component

```heex
<MyAppWeb.Components.Badge.badge label="new" kind={:info} />
```

### Self-closing

```heex
<.icon name="hero-trash" class="w-5 h-5" />
```

---

## Slots

### Default slot (inner_block)

```heex
<.button>Click me</.button>
```

### Named slots

```heex
<.card>
  <:header>Title</:header>
  Body content
  <:footer>
    <.button>Action</.button>
  </:footer>
</.card>
```

### Slot attributes

```heex
<.table rows={@users}>
  <:col :let={user} label="Name">{user.name}</:col>
  <:col :let={user} label="Email">{user.email}</:col>
  <:action :let={user}>
    <.link navigate={~p"/users/#{user}"}>Show</.link>
  </:action>
</.table>
```

---

## Dynamic attributes

Spread a map/keyword into element attributes:

```heex
<div {@rest}>Content</div>
<input {@input_attrs} />
```

---

## Attribute behavior

| Value             | Rendered as                          |
|-------------------|--------------------------------------|
| `true`            | Boolean attribute: `<input required>`|
| `false` / `nil`   | Attribute omitted entirely          |
| list (on `class`) | Flattened, nils filtered             |

```heex
<div class={["base", @active && "active", @size_class]}>
```

---

## phx- bindings

### Click events

```heex
<button phx-click="increment">+1</button>
<button phx-click={JS.push("delete", value: %{id: @id})}>Delete</button>
<div phx-click-away={JS.hide(to: "#dropdown")}>Dropdown</div>
```

### Form events

```heex
<.form for={@form} phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} phx-debounce="300" />
</.form>
```

### Key events

```heex
<div phx-window-keydown="keypress" phx-key="Escape">
<input phx-keydown="search" phx-debounce="300" />
```

Not supported on inputs for keydown/keyup — use `phx-change` instead.

### Focus events

```heex
<input phx-focus="field_focused" phx-blur="field_blurred" />
<div phx-window-focus="tab_visible" phx-window-blur="tab_hidden" />
```

### Passing values

```heex
<button phx-click="delete" phx-value-id={item.id} phx-value-type="soft">
  Delete
</button>
```

Server receives: `%{"id" => "123", "type" => "soft"}`.

### Loading states

```heex
<button phx-click="save" phx-disable-with="Saving...">Save</button>

<%!-- CSS classes added automatically: --%>
<%!-- phx-click-loading (on element) --%>
<%!-- phx-submit-loading (on form) --%>
<%!-- phx-change-loading (on form) --%>
```

### DOM lifecycle

```heex
<div phx-mounted={JS.transition("fade-in")}>Appears with animation</div>
<div phx-remove={JS.hide(transition: "fade-out")}>Removed with animation</div>
```

### Connection state

```heex
<div phx-connected={JS.remove_class("opacity-50")}
     phx-disconnected={JS.add_class("opacity-50")}>
  Content dims when disconnected
</div>
```

### Scroll / infinite pagination

```heex
<div id="items" phx-update="stream"
     phx-viewport-top="load_previous"
     phx-viewport-bottom="load_more">
  <div :for={{dom_id, item} <- @streams.items} id={dom_id}>
    {item.name}
  </div>
</div>
```

### JavaScript hooks

```heex
<div id="chart" phx-hook="ChartHook" data-values={Jason.encode!(@values)}>
</div>
```

Hook module (in app.js):

```javascript
let ChartHook = {
  mounted() { this.renderChart() },
  updated() { this.renderChart() },
  renderChart() { /* use this.el.dataset.values */ }
}
```

### Rate limiting

```heex
<input phx-change="search" phx-debounce="300" />     <%!-- wait 300ms after last input --%>
<input phx-change="search" phx-debounce="blur" />     <%!-- fire on blur --%>
<input phx-change="track" phx-throttle="1000" />      <%!-- max once per second --%>
```

### Targeting components

```heex
<button phx-click="save" phx-target={@myself}>Save in component</button>
```

---

## DOM patching

```heex
<%!-- Default: LiveView patches content --%>
<div id="content">Updated by server</div>

<%!-- Stream: client-managed collection --%>
<div id="items" phx-update="stream">...</div>

<%!-- Ignore: never patch this element --%>
<div id="external-widget" phx-update="ignore">
  Managed by JS only
</div>
```

---

## Change tracking

LiveView tracks assigns and only re-renders changed parts. Avoid breaking tracking:

```heex
<%!-- GOOD: direct assign access --%>
{@user.name}

<%!-- BAD: defeats change tracking --%>
<% user = @user %>
{user.name}
```

Static parts of comprehensions are sent once regardless of collection size.

---

## Comments

```heex
<%!-- This is a HEEx comment (not sent to client) --%>
<!-- This is an HTML comment (sent to client) -->
```
