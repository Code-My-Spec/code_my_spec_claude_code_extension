# LiveView Forms

## Sources
- https://hexdocs.pm/phoenix_live_view/form-bindings.html
- https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html
- https://hexdocs.pm/phoenix_live_view/bindings.html

---

## Form setup

### Mount: initialize the form

```elixir
def mount(_params, _session, socket) do
  changeset = Accounts.change_user(%User{})
  {:ok, assign(socket, form: to_form(changeset))}
end
```

### Template: .form component

```heex
<.form for={@form} id="user-form" phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:email]} type="email" label="Email" />
  <.input field={@form[:role]} type="select" label="Role"
    options={[{"Admin", "admin"}, {"User", "user"}]} />
  <:actions>
    <.button phx-disable-with="Saving...">Save</.button>
  </:actions>
</.form>
```

---

## to_form/2

Converts a changeset (or map) into a `Phoenix.HTML.Form` struct for templates.

```elixir
to_form(changeset)                          # basic
to_form(changeset, action: :validate)       # marks as validated (shows errors)
to_form(changeset, as: "user")              # custom param key
to_form(%{"name" => ""}, as: "user")        # from plain map
```

The `:action` option controls when errors display. Without it, changeset errors exist but `used_input?/1` gates their visibility.

---

## Validation (phx-change)

```elixir
def handle_event("validate", %{"user" => params}, socket) do
  form =
    %User{}
    |> Accounts.change_user(params)
    |> Map.put(:action, :validate)
    |> to_form()

  {:noreply, assign(socket, form: form)}
end
```

Alternatively, pass action to `to_form`:

```elixir
changeset
|> to_form(action: :validate)
```

---

## Submission (phx-submit)

```elixir
def handle_event("save", %{"user" => params}, socket) do
  case Accounts.create_user(params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "User created")
       |> push_navigate(to: ~p"/users/#{user}")}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

---

## Edit forms

```elixir
def mount(%{"id" => id}, _session, socket) do
  user = Accounts.get_user!(id)
  changeset = Accounts.change_user(user)
  {:ok, assign(socket, user: user, form: to_form(changeset))}
end

def handle_event("save", %{"user" => params}, socket) do
  case Accounts.update_user(socket.assigns.user, params) do
    {:ok, user} ->
      {:noreply,
       socket
       |> put_flash(:info, "Updated")
       |> push_navigate(to: ~p"/users/#{user}")}

    {:error, changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end
```

---

## Error display

### used_input?/1

Only shows errors for fields the user has interacted with. LiveView sends `_unused_` prefixed params for untouched fields.

```elixir
def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
  errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []
  assigns = assign(assigns, :errors, Enum.map(errors, &translate_error/1))
  # ...
end
```

### Rendering errors

```heex
<p :for={msg <- @errors} class="text-error text-sm">{msg}</p>
```

---

## Nested forms (associations)

Use `.inputs_for` for `has_many` / `embeds_many`:

```heex
<.inputs_for :let={addr_form} field={@form[:addresses]}>
  <.input field={addr_form[:street]} label="Street" />
  <.input field={addr_form[:city]} label="City" />
</.inputs_for>
```

Requires `cast_assoc/3` or `cast_embed/3` in the changeset.

---

## Special input types

### Select

```heex
<.input field={@form[:role]} type="select" label="Role"
  options={[{"Admin", "admin"}, {"User", "user"}]} />
```

### Checkbox

```heex
<.input field={@form[:active]} type="checkbox" label="Active" />
```

### Textarea

```heex
<.input field={@form[:bio]} type="textarea" label="Bio" />
```

### File upload

```heex
<.live_file_input upload={@uploads.avatar} />
```

Requires `allow_upload/3` in mount.

### Password

Set `:value` explicitly (browsers clear password fields):

```heex
<.input field={@form[:password]} type="password" label="Password"
  value={@form[:password].value} />
```

---

## Debounce & throttle

```heex
<.input field={@form[:search]} phx-debounce="300" />    <%!-- delay 300ms --%>
<.input field={@form[:search]} phx-debounce="blur" />    <%!-- on blur only --%>
<.input field={@form[:slider]} phx-throttle="500" />     <%!-- max every 500ms --%>
```

Default for both: 300ms.

---

## Submit button states

```heex
<%!-- Text swap during submit --%>
<button type="submit" phx-disable-with="Saving...">Save</button>

<%!-- CSS classes applied during submit --%>
<%!-- form gets: phx-submit-loading --%>
<%!-- inputs become: readonly --%>
<%!-- submit button: disabled --%>
```

---

## Form recovery

Forms with both `phx-change` and `id` auto-recover values after reconnect.

```heex
<%!-- Custom recovery event --%>
<.form phx-auto-recover="recover_form" ...>

<%!-- Disable recovery --%>
<.form phx-auto-recover="ignore" ...>
```

---

## Form reset

A `<button type="reset">` emits `phx-change` with `_target: ["reset"]`:

```elixir
def handle_event("validate", %{"_target" => ["reset"]}, socket) do
  {:noreply, assign(socket, form: to_form(Accounts.change_user(%User{})))}
end
```

---

## Complete form LiveView pattern

```elixir
defmodule MyAppWeb.UserLive.Form do
  use MyAppWeb, :live_view

  alias MyApp.Accounts
  alias MyApp.Accounts.User

  def mount(params, _session, socket) do
    {user, action} =
      case params do
        %{"id" => id} -> {Accounts.get_user!(id), :edit}
        _ -> {%User{}, :new}
      end

    changeset = Accounts.change_user(user)

    {:ok,
     assign(socket,
       user: user,
       action: action,
       form: to_form(changeset)
     )}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"user" => params}, socket) do
    save(socket, socket.assigns.action, params)
  end

  defp save(socket, :new, params) do
    case Accounts.create_user(params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created")
         |> push_navigate(to: ~p"/users/#{user}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save(socket, :edit, params) do
    case Accounts.update_user(socket.assigns.user, params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated")
         |> push_navigate(to: ~p"/users/#{user}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
```
