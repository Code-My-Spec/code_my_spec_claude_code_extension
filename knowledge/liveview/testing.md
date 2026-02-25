# LiveView Testing

## Sources
- https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html

---

## Setup

```elixir
import Phoenix.LiveViewTest
import Plug.Conn
import Phoenix.ConnTest
```

---

## Mounting LiveViews

### Disconnected then connected mount

```elixir
test "disconnected and connected mount", %{conn: conn} do
  conn = get(conn, "/my-path")
  assert html_response(conn, 200) =~ "<h1>My View</h1>"
  {:ok, view, html} = live(conn)
end
```

### Connected mount (single step)

```elixir
test "connected mount", %{conn: conn} do
  {:ok, _view, html} = live(conn, "/my-path")
  assert html =~ "<h1>My View</h1>"
end
```

### Connect params and info

```elixir
{:ok, view, html} =
  conn
  |> put_connect_params(%{"param" => "value"})
  |> live("/my-path")
```

### Isolated mount (non-routable LiveViews)

```elixir
{:ok, view, html} =
  live_isolated(conn, MyAppWeb.ClockLive, session: %{"tz" => "EST"})
```

### Error handling options

```elixir
live(conn, "/path", on_error: :raise)   # default — raise on errors
live(conn, "/path", on_error: :warn)    # log warnings instead
```

---

## Element & Form Selectors

### element/3 — select a DOM element

```elixir
view |> element("button", "Increment")       # CSS selector + text filter
view |> element("#term > :first-child")       # CSS selector only
view |> element("a", ~r{(?<!un)opened})       # regex text filter
view |> element(~s{[href="/foo"][id="bar"]})  # attribute selector
```

### form/3 — select a form with pre-filled data

```elixir
form = view |> form("#user-form", user: %{name: "hello"})
```

Form data is validated against the actual markup — raises if input names don't exist.

### has_element?/3 — check element existence

```elixir
assert view |> element("#some-element") |> has_element?()
assert has_element?(view, "#some-element")
assert has_element?(view, "a", "Delete")
```

---

## Click Events

### Element-targeted (preferred — validates phx-click exists)

```elixir
assert view
       |> element("button", "Increment")
       |> render_click() =~ "The temperature is: 31℉"
```

### View-targeted (bypasses markup validation)

```elixir
assert render_click(view, :inc) =~ "The temperature is: 31℉"
assert render_click(view, :inc, %{value: 1}) =~ "31℉"
```

---

## Form Events

### Change (phx-change)

```elixir
assert view
       |> element("form")
       |> render_change(%{deg: 123}) =~ "123 exceeds limits"

# With _target metadata
assert view
       |> element("form")
       |> render_change(%{_target: ["deg"], deg: 123}) =~ "123 exceeds limits"
```

### Submit (phx-submit)

```elixir
assert view
       |> element("form")
       |> render_submit(%{deg: 123}) =~ "submitted"

# Via form/3 helper
assert view
       |> form("#user-form", user: %{name: "hello"})
       |> render_submit() =~ "Name updated"

# With additional hidden fields
assert view
       |> form("#user-form", user: %{name: "hello"})
       |> render_submit(%{user: %{"hidden_field" => "value"}}) =~ "updated"
```

### Submitter (button name attribute)

```elixir
assert view
       |> form("#my-form", %{})
       |> put_submitter("button[name=example_action]")
       |> render_submit() =~ "Action taken"
```

---

## Keyboard Events

```elixir
# Element-targeted
assert view |> element("#inc") |> render_keydown() =~ "31℉"
assert view |> element("#inc") |> render_keyup() =~ "31℉"

# View-targeted with event name
assert render_keydown(view, :inc) =~ "31℉"
assert render_keyup(view, :inc) =~ "31℉"

# With key value
assert render_keydown(view, :inc, %{"key" => "Enter"}) =~ "31℉"
```

---

## Focus & Blur Events

```elixir
assert view |> element("#field") |> render_focus() =~ "focused"
assert view |> element("#field") |> render_blur() =~ "blurred"
```

---

## Hook Events

```elixir
# View-targeted
assert render_hook(view, :refresh, %{deg: 32}) =~ "32℉"

# Component-targeted via phx-target
assert view
       |> element("#thermo-component")
       |> render_hook(:refresh, %{deg: 32}) =~ "32℉"
```

---

## Rendering

### Current state

```elixir
assert render(view) =~ "some content"
assert view |> element("#alarm") |> render() == "Snooze"
```

### Async content (assign_async / start_async)

```elixir
{:ok, lv, html} = live(conn, "/path")
assert html =~ "loading data..."
assert render_async(lv) =~ "data loaded!"
```

### Page title

```elixir
render_click(view, :update_title)
assert page_title(view) =~ "my title"
```

### Render a function component (no LiveView needed)

```elixir
assert render_component(&MyComponents.greet/1, name: "Mary") =~
         "Hello, Mary!"
```

### Render a LiveComponent

```elixir
assert render_component(MyComponent, id: 123, user: %User{}) =~
         "some markup"

# With router for link helpers
assert render_component(MyComponent, %{id: 123}, router: MyRouter) =~
         "some markup"
```

---

## Navigation & Redirects

### assert_patch — LiveView stays alive, URL changes

```elixir
render_click(view, :go_to_page)
assert_patch view                       # any patch
assert_patch view, "/expected/path"     # specific path
assert_patch view, "/path", 30          # custom timeout (ms)
```

### assert_redirect — LiveView dies, full navigation

```elixir
render_click(view, :redirect_away)
{path, flash} = assert_redirect view
assert flash["info"] == "Welcome"

# Specific path
flash = assert_redirect view, "/expected/path"
```

### assert_redirected — redirect already happened

```elixir
assert_redirected view, "/expected/path"
```

### refute_redirected

```elixir
:ok = refute_redirected view, "/wrong_path"
```

### follow_redirect — follow and get the new view/conn

```elixir
# From render result
{:ok, new_view, html} =
  view
  |> render_click("redirect")
  |> follow_redirect(conn)

# Assert on path
{:ok, new_view, html} =
  view
  |> render_click("redirect")
  |> follow_redirect(conn, "/redirected/page")

# From error tuple (mount redirect)
assert {:error, {:redirect, %{to: "/somewhere"}}} = result = live(conn, "/my-path")
{:ok, view, html} = follow_redirect(result, conn)
```

### render_patch — simulate a patch URL change

```elixir
render_patch(view, "/new/path")
```

### live_redirect — simulate live navigation

```elixir
assert {:error, {:redirect, _}} = live_redirect(view, to: "/admin")
```

---

## Push Event Assertions

### assert_push_event — server pushed event to client hook

```elixir
assert_push_event view, "scores", %{points: 100, user: "josé"}
```

### refute_push_event

```elixir
refute_push_event view, "scores", %{points: _, user: "josé"}
```

### assert_reply — hook reply

```elixir
assert_reply view, %{result: "ok", transaction_id: _}
```

---

## File Upload Testing

### Create file input

```elixir
avatar = file_input(view, "#my-form-id", :avatar, [%{
  last_modified: 1_594_171_879_000,
  name: "myfile.jpeg",
  content: File.read!("myfile.jpg"),
  size: 1_396_009,
  type: "image/jpeg"
}])
```

### Upload the file

```elixir
# Full upload
assert render_upload(avatar, "myfile.jpeg") =~ "100%"

# Chunked upload (percentage per call)
assert render_upload(avatar, "myfile.jpeg", 49) =~ "49%"
assert render_upload(avatar, "myfile.jpeg", 51) =~ "100%"
```

### Preflight upload

```elixir
assert {:ok, %{ref: _ref, config: %{chunk_size: _}}} = preflight_upload(avatar)
```

---

## Child LiveViews

### Find a specific child

```elixir
{:ok, view, _html} = live(conn, "/thermo")
assert clock_view = find_live_child(view, "clock")
assert render_click(clock_view, :snooze) =~ "snoozing"
```

### List all children

```elixir
assert [clock_view] = live_children(view)
```

---

## Sending Messages

LiveViews are GenServers — send messages directly:

```elixir
send(view.pid, {:set_temp, 50})
assert render(view) =~ "The temperature is: 50℉"
```

---

## Target Scoping (phx-target)

```elixir
view
|> with_target("#user-1,#user-2")
|> render_click("Hide", %{})
```

---

## Trigger Action (form-to-plug pipeline)

When `phx-trigger-action` is used to submit a form through the plug pipeline:

```elixir
form = form(view, "#my-form", %{"form" => "data"})
assert render_submit(form) =~ ~r/phx-trigger-action/
conn = follow_trigger_action(form, conn)
assert conn.method == "POST"
```

---

## Debugging

```elixir
# Open rendered HTML in browser
view
|> element("#term > :first-child")
|> open_browser()
```

---

## Best Practices

| Prefer                                        | Over                                    | Why                              |
|-----------------------------------------------|-----------------------------------------|----------------------------------|
| `element("button") \|> render_click()`        | `render_click(view, :event)`            | Validates phx-click exists       |
| `form("#form", data) \|> render_submit()`     | `render_submit(view, :save, data)`      | Validates input names exist      |
| `assert_patch view, "/path"`                  | Manual path checking                    | Handles async timing             |
| `has_element?(view, selector)`                | `render(view) =~ "text"`               | Precise, less brittle            |

---

## Complete LiveView Test Pattern

```elixir
defmodule MyAppWeb.ThingLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.ThingsFixtures

  @create_attrs %{name: "new thing"}
  @update_attrs %{name: "updated thing"}
  @invalid_attrs %{name: nil}

  setup :register_and_log_in_user

  defp create_thing(%{scope: scope}) do
    thing = thing_fixture(scope)
    %{thing: thing}
  end

  describe "Index" do
    setup [:create_thing]

    test "lists all things", %{conn: conn, thing: thing} do
      {:ok, _live, html} = live(conn, ~p"/things")
      assert html =~ "Listing Things"
      assert html =~ thing.name
    end

    test "deletes thing", %{conn: conn, thing: thing} do
      {:ok, live, _html} = live(conn, ~p"/things")

      assert live
             |> element("#things-#{thing.id} a", "Delete")
             |> render_click()

      refute has_element?(live, "#things-#{thing.id}")
    end
  end

  describe "New" do
    test "creates a new thing", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/things/new")

      assert live
             |> form("#thing-form", thing: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert live
             |> form("#thing-form", thing: @create_attrs)
             |> render_submit()

      assert_patch live, ~p"/things"
      assert render(live) =~ "Thing created successfully"
    end
  end

  describe "Show" do
    setup [:create_thing]

    test "displays thing", %{conn: conn, thing: thing} do
      {:ok, _live, html} = live(conn, ~p"/things/#{thing}")
      assert html =~ "Show Thing"
      assert html =~ thing.name
    end
  end

  describe "Edit" do
    setup [:create_thing]

    test "updates thing", %{conn: conn, thing: thing} do
      {:ok, live, _html} = live(conn, ~p"/things/#{thing}/edit")

      assert live
             |> form("#thing-form", thing: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert live
             |> form("#thing-form", thing: @update_attrs)
             |> render_submit()

      assert_patch live, ~p"/things/#{thing}"
      assert render(live) =~ "Thing updated successfully"
    end
  end
end
```
