# Core Components

## Sources
- https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html

---

## Function Component Definition

Stateless functions: receives assigns map, returns `~H` template.

```elixir
defmodule MyAppWeb.Components.Badge do
  use Phoenix.Component

  attr :label, :string, required: true
  attr :kind, :atom, values: [:info, :success, :warning, :error], default: :info

  def badge(assigns) do
    ~H"""
    <span class={"badge badge-#{@kind}"}>{@label}</span>
    """
  end
end
```

---

## attr/3

Declares accepted attributes with compile-time validation.

```elixir
attr name, type, opts \\ []
```

### Types

| Type              | Description                              |
|-------------------|------------------------------------------|
| `:string`         | String value                             |
| `:atom`           | Atom value                               |
| `:boolean`        | Boolean (true renders attr, false omits) |
| `:integer`        | Integer value                            |
| `:float`          | Float value                              |
| `:list`           | List value                               |
| `:map`            | Map value                                |
| `:any`            | Any type                                 |
| `:global`         | Dynamic HTML/phx-* attributes            |
| `{:fun, arity}`   | Function with given arity                |
| `MyStruct`        | Struct module                            |

### Options

| Option       | Purpose                                       |
|--------------|-----------------------------------------------|
| `:required`  | Must be provided by caller                    |
| `:default`   | Fallback value if not provided                |
| `:values`    | Exhaustive list of allowed values             |
| `:examples`  | Example values (documentation)                |
| `:doc`       | Attribute documentation string                |

### :global attributes

Accepts any HTML global attribute + `phx-*` bindings. Render with `{@rest}`.

```elixir
attr :rest, :global, default: %{class: ""}

def card(assigns) do
  ~H"""
  <div {@rest}>
    {render_slot(@inner_block)}
  </div>
  """
end
```

Extend with custom prefixes:

```elixir
use Phoenix.Component, global_prefixes: ~w(x-)
```

---

## slot/3

Declares content blocks.

```elixir
slot name, opts \\ [], do: block
```

### Default slot

```elixir
slot :inner_block, required: true

def button(assigns) do
  ~H"""
  <button class="btn">{render_slot(@inner_block)}</button>
  """
end
```

Usage:

```heex
<.button>Click me</.button>
```

### Named slots

```elixir
slot :header
slot :inner_block, required: true
slot :footer

def panel(assigns) do
  ~H"""
  <div class="card">
    <header :if={@header != []}>{render_slot(@header)}</header>
    <div class="card-body">{render_slot(@inner_block)}</div>
    <footer :if={@footer != []}>{render_slot(@footer)}</footer>
  </div>
  """
end
```

Usage:

```heex
<.panel>
  <:header>Title</:header>
  Body content
  <:footer>Actions</:footer>
</.panel>
```

### Slots with attributes

```elixir
slot :column, required: true do
  attr :label, :string, required: true
  attr :class, :string
end

def data_table(assigns) do
  ~H"""
  <table class="table">
    <thead>
      <tr>
        <th :for={col <- @column}>{col.label}</th>
      </tr>
    </thead>
    <tbody>
      <tr :for={row <- @rows}>
        <td :for={col <- @column} class={col[:class]}>
          {render_slot(col, row)}
        </td>
      </tr>
    </tbody>
  </table>
  """
end
```

Usage:

```heex
<.data_table rows={@users}>
  <:column :let={user} label="Name">{user.name}</:column>
  <:column :let={user} label="Email">{user.email}</:column>
</.data_table>
```

---

## render_slot/2

Renders slot content, optionally passing a value to `:let`.

```elixir
render_slot(@inner_block)           # render default slot
render_slot(@inner_block, @form)    # pass value to :let
render_slot(@column, row)           # pass value to named slot :let
```

When a named slot has multiple entries, `render_slot/2` renders all of them.
To access individual slot attrs, iterate: `:for={col <- @column}`.

---

## Standard core_components.ex

Phoenix generators produce `core_components.ex` with these typical components:

| Component       | Purpose                          | Key attrs/slots             |
|-----------------|----------------------------------|-----------------------------|
| `.button`       | Button element                   | `type`, `class`, `rest`     |
| `.input`        | Form input with label+errors     | `field`, `type`, `label`    |
| `.simple_form`  | Form wrapper with submit         | `for`, `as`, `rest`         |
| `.table`        | Data table with slots            | `rows`, `:col`, `:action`   |
| `.modal`        | Dialog modal                     | `id`, `show`, `on_cancel`   |
| `.flash`        | Flash message                    | `kind`, `flash`             |
| `.flash_group`  | All flash messages               | `flash`                     |
| `.header`       | Page header with actions         | `:actions`, `:subtitle`     |
| `.back`         | Back navigation link             | `navigate`                  |
| `.icon`         | Hero icon by name                | `name`, `class`             |
| `.error`        | Error text                       | inner_block                 |
| `.label`        | Form label                       | `for`                       |
| `.list`         | Description list                 | `:item` with `title`        |

### Typical .input pattern

```elixir
attr :id, :any, default: nil
attr :name, :any
attr :label, :string, default: nil
attr :value, :any
attr :type, :string, default: "text",
  values: ~w(checkbox color date datetime-local email file hidden month
             number password range search select tel text textarea time url week)
attr :field, Phoenix.HTML.FormField
attr :errors, :list, default: []
attr :checked, :boolean
attr :prompt, :string, default: nil
attr :options, :list
attr :multiple, :boolean, default: false
attr :rest, :global, include: ~w(accept autocomplete capture cols disabled
  form list max maxlength min minlength multiple pattern placeholder
  readonly required rows size step)
slot :inner_block

def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
  errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
  # ... build input with error display
end
```

---

## dynamic_tag/1

Render an HTML tag with a runtime-determined name.

```elixir
<.dynamic_tag tag_name={@tag} class="text-lg">
  Content
</.dynamic_tag>
```

Raises `ArgumentError` for unsafe tag names.

---

## assign helpers

```elixir
assign(socket, key: "value")              # keyword
assign(socket, %{key: "value"})           # map
assign(socket, :key, "value")             # single key
assign_new(socket, :user, fn -> load() end)  # lazy, skips if key exists
```
