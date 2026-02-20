# Phoenix Conventions

## Sources
- Phoenix generator templates: `phx.gen.live`, `phx.gen.context`, `phx.gen.schema`, `phx.gen.auth`

---

## Layered Architecture

```
Request
  │
  ▼
Router  ─── live_session groups with on_mount hooks
  │
  ▼
LiveView  ─── UI state, events, streams, PubSub
  │
  ▼
Context  ─── public API, scope enforcement, broadcasts
  │
  ▼
Schema  ─── changesets, validations, type definitions
  │
  ▼
Repo  ─── Ecto database operations
```

| Layer        | Knows about       | Never touches               |
|--------------|-------------------|-----------------------------|
| LiveView     | Context           | Repo, Schema internals      |
| Context      | Schema, Repo      | Conn, Socket, LiveView      |
| Schema       | Ecto.Changeset    | Repo, Context, LiveView     |

> Compile-time enforcement of these layers uses the `boundary` library. See `boundary.md` for setup and declaration patterns.

---

## Naming Conventions

| Concept            | Pattern                                  | Example                               |
|--------------------|------------------------------------------|---------------------------------------|
| Context module     | `App.PluralDomain`                       | `MyApp.Products`                      |
| Schema module      | `App.PluralDomain.Singular`              | `MyApp.Products.Product`              |
| LiveView module    | `AppWeb.SingularLive.Action`             | `MyAppWeb.ProductLive.Index`          |
| Migration          | `Create{Table}`                          | `CreateProducts`                      |
| Fixture module     | `App.PluralDomainFixtures`               | `MyApp.ProductsFixtures`              |
| Test module        | `App.PluralDomainTest`                   | `MyApp.ProductsTest`                  |

### Function naming

| Operation     | Context function            | Notes                               |
|---------------|-----------------------------|-------------------------------------|
| List all      | `list_plural(scope)`        | Returns `[%Schema{}]`               |
| Get (bang)    | `get_singular!(scope, id)`  | Raises on not found                 |
| Get (safe)    | `get_singular(scope, id)`   | Returns `{:ok, schema}` or `{:error, :not_found}` |
| Create        | `create_singular(scope, attrs)` | Returns `{:ok, schema}` or `{:error, changeset}` |
| Update        | `update_singular(scope, schema, attrs)` | Returns `{:ok, schema}` or `{:error, changeset}` |
| Delete        | `delete_singular(scope, schema)` | Returns `{:ok, schema}` or `{:error, changeset}` |
| Changeset     | `change_singular(scope, schema, attrs \\\\ %{})` | Returns `%Ecto.Changeset{}` |
| Subscribe     | `subscribe_plural(scope)`   | PubSub subscription                 |

---

## Context Module Pattern

```elixir
defmodule MyApp.Things do
  @moduledoc """
  The Things context.
  """

  import Ecto.Query, warn: false
  alias MyApp.Repo
  alias MyApp.Things.Thing
  alias MyApp.Users.Scope

  ## PubSub

  def subscribe_things(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "user:#{scope.user.id}:things")
  end

  defp broadcast(%Scope{} = scope, message) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, "user:#{scope.user.id}:things", message)
  end

  ## CRUD — scope is always the first parameter

  def list_things(%Scope{} = scope) do
    Repo.all_by(Thing, user_id: scope.user_id)
  end

  def get_thing!(%Scope{} = scope, id) do
    Repo.get_by!(Thing, id: id, user_id: scope.user_id)
  end

  def create_thing(%Scope{} = scope, attrs) do
    with {:ok, thing = %Thing{}} <-
           %Thing{}
           |> Thing.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, thing})
      {:ok, thing}
    end
  end

  def update_thing(%Scope{} = scope, %Thing{} = thing, attrs) do
    true = thing.user_id == scope.user_id  # ownership assertion

    with {:ok, thing = %Thing{}} <-
           thing
           |> Thing.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, thing})
      {:ok, thing}
    end
  end

  def delete_thing(%Scope{} = scope, %Thing{} = thing) do
    true = thing.user_id == scope.user_id

    with {:ok, thing = %Thing{}} <- Repo.delete(thing) do
      broadcast(scope, {:deleted, thing})
      {:ok, thing}
    end
  end

  def change_thing(%Scope{} = scope, %Thing{} = thing, attrs \\ %{}) do
    true = thing.user_id == scope.user_id
    Thing.changeset(thing, attrs, scope)
  end
end
```

---

## Schema Pattern

```elixir
defmodule MyApp.Things.Thing do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          id: Ecto.UUID.t() | nil,
          name: String.t(),
          status: :active | :archived,
          user_id: integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "things" do
    field :name, :string
    field :status, Ecto.Enum, values: [:active, :archived], default: :active

    belongs_to :user, MyApp.Users.User
    has_many :items, MyApp.Things.Item, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(thing, attrs, scope) do
    thing
    |> cast(attrs, [:name, :status])
    |> validate_required([:name])
    |> put_change(:user_id, scope.user_id)
  end
end
```

### Key schema conventions

| Convention                    | Pattern                                        |
|-------------------------------|------------------------------------------------|
| Primary key                   | `@primary_key {:id, :binary_id, autogenerate: true}` |
| Timestamps                    | `timestamps(type: :utc_datetime)`              |
| Enums                         | `field :status, Ecto.Enum, values: [...]`      |
| Foreign keys (belongs_to)     | `belongs_to :user, MyApp.Users.User`           |
| FK with binary_id type        | `belongs_to :category, Category, type: :binary_id` |
| Typespec                      | `@type t :: %__MODULE__{...}` with all fields  |
| Scope in changeset            | `def changeset(struct, attrs, scope)`          |

### Changeset patterns

```elixir
# Standard pipeline: cast → validate → constrain
def changeset(thing, attrs, scope) do
  thing
  |> cast(attrs, [:name, :email, :status])
  |> validate_required([:name, :email])
  |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/)
  |> validate_length(:name, min: 1, max: 100)
  |> unique_constraint(:email)
  |> put_change(:user_id, scope.user_id)
end

# Multiple specialized changesets for different operations
def password_changeset(user, attrs, opts \\ []) do
  user
  |> cast(attrs, [:password])
  |> validate_confirmation(:password, message: "does not match")
  |> validate_length(:password, min: 12, max: 72)
end

# Nested associations via cast_assoc
def changeset(order, attrs) do
  order
  |> cast(attrs, [:status])
  |> cast_assoc(:line_items,
    with: &LineItem.changeset/2,
    sort_param: :line_items_sort,
    drop_param: :line_items_drop
  )
end
```

---

## Scope / Multi-Tenancy

`phx.gen.auth` generates a `Scope` struct that threads caller identity through every layer. The generator creates a minimal struct with `user` and `user_id` — extend it as your app grows.

```elixir
defstruct user: nil, user_id: nil

@type t :: %__MODULE__{
        user: User.t() | nil,
        user_id: integer() | nil
      }

def for_user(%User{} = user) do
  %__MODULE__{user: user, user_id: user.id}
end

def for_user(nil), do: nil
```

When you add a `--scope` flag to generators (e.g. `mix phx.gen.live Things Thing things name --scope Scope`), the generated code threads scope through all context functions:

| Rule                          | How                                            |
|-------------------------------|------------------------------------------------|
| Scope is always first param   | `def list_things(%Scope{} = scope)`            |
| Ownership assertion on write  | `true = thing.user_id == scope.user.id`        |
| Scope sets owner in changeset | `put_change(:user_id, scope.user.id)`          |
| Query scoping on read         | `Repo.all_by(Thing, user_id: scope.user_id)`   |
| PubSub scoped to user         | `"user:#{scope.user.id}:things"`               |

---

## LiveView Module Structure

Three modules per resource: `Index`, `Show`, `Form`.

### Index — list + delete + PubSub

```elixir
defmodule MyAppWeb.ThingLive.Index do
  use MyAppWeb, :live_view

  alias MyApp.Things

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} scope={@scope}>
      <.header>
        Listing Things
        <:actions>
          <.button variant="primary" navigate={~p"/things/new"}>
            <.icon name="hero-plus" /> New Thing
          </.button>
        </:actions>
      </.header>

      <.table id="things" rows={@streams.things}
        row_click={fn {_id, thing} -> JS.navigate(~p"/things/#{thing}") end}>
        <:col :let={{_id, thing}} label="Name">{thing.name}</:col>
        <:action :let={{id, thing}}>
          <.link navigate={~p"/things/#{thing}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, thing}}>
          <.link phx-click={JS.push("delete", value: %{id: thing.id}) |> hide("##{id}")}
            data-confirm="Are you sure?">Delete</.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.scope
    if connected?(socket), do: Things.subscribe_things(scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Things")
     |> stream(:things, Things.list_things(scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    scope = socket.assigns.scope
    thing = Things.get_thing!(scope, id)
    {:ok, _} = Things.delete_thing(scope, thing)
    {:noreply, stream_delete(socket, :things, thing)}
  end

  @impl true
  def handle_info({type, %Thing{}}, socket)
      when type in [:created, :updated, :deleted] do
    scope = socket.assigns.scope
    {:noreply, stream(socket, :things, Things.list_things(scope), reset: true)}
  end
end
```

### Form — handles both `:new` and `:edit` via `live_action`

```elixir
defmodule MyAppWeb.ThingLive.Form do
  use MyAppWeb, :live_view

  alias MyApp.Things

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    scope = socket.assigns.scope
    thing = %Thing{user_id: scope.user_id}

    socket
    |> assign(:page_title, "New Thing")
    |> assign(:thing, thing)
    |> assign(:form, to_form(Things.change_thing(scope, thing)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    scope = socket.assigns.scope
    thing = Things.get_thing!(scope, id)

    socket
    |> assign(:page_title, "Edit Thing")
    |> assign(:thing, thing)
    |> assign(:form, to_form(Things.change_thing(scope, thing)))
  end

  @impl true
  def handle_event("validate", %{"thing" => params}, socket) do
    scope = socket.assigns.scope
    changeset = Things.change_thing(scope, socket.assigns.thing, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"thing" => params}, socket) do
    save_thing(socket, socket.assigns.live_action, params)
  end

  defp save_thing(socket, :new, params) do
    scope = socket.assigns.scope
    case Things.create_thing(scope, params) do
      {:ok, thing} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thing created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, thing))}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
```

### Show — display + real-time updates

```elixir
def mount(%{"id" => id}, _session, socket) do
  scope = socket.assigns.scope
  if connected?(socket), do: Things.subscribe_things(scope)

  {:ok,
   socket
   |> assign(:page_title, "Show Thing")
   |> assign(:thing, Things.get_thing!(scope, id))}
end

@impl true
def handle_info({:updated, %Thing{id: id} = thing},
    %{assigns: %{thing: %{id: id}}} = socket) do
  {:noreply, assign(socket, :thing, thing)}
end

def handle_info({:deleted, %Thing{id: id}},
    %{assigns: %{thing: %{id: id}}} = socket) do
  {:noreply,
   socket
   |> put_flash(:error, "This thing was deleted.")
   |> push_navigate(to: ~p"/things")}
end

# Ignore events for other records
def handle_info({type, %Thing{}}, socket)
    when type in [:created, :updated, :deleted] do
  {:noreply, socket}
end
```

---

## Router / live_session Organization

Routes are grouped into `live_session` blocks by authentication level. Each session declares `on_mount` hooks that run before the LiveView mounts.

```elixir
# Public — scope may or may not have a user
live_session :current_user,
  on_mount: [{MyAppWeb.UserAuth, :mount_current_scope}] do
  live "/users/register", UserLive.Registration, :new
  live "/users/log-in", UserLive.Login, :new
end

# Authenticated — user required
live_session :require_authenticated_user,
  on_mount: [{MyAppWeb.UserAuth, :require_authenticated}] do
  live "/users/settings", UserLive.Settings, :edit

  live "/things", ThingLive.Index, :index
  live "/things/new", ThingLive.Form, :new
  live "/things/:id", ThingLive.Show, :show
  live "/things/:id/edit", ThingLive.Form, :edit
end
```

### Route patterns per resource

| Action | Path                     | LiveView            | live_action |
|--------|--------------------------|---------------------|-------------|
| List   | `/things`                | `ThingLive.Index`   | `:index`    |
| New    | `/things/new`            | `ThingLive.Form`    | `:new`      |
| Show   | `/things/:id`            | `ThingLive.Show`    | `:show`     |
| Edit   | `/things/:id/edit`       | `ThingLive.Form`    | `:edit`     |

---

## PubSub Pattern

Contexts own the subscribe/broadcast cycle. LiveViews subscribe on connect.

```elixir
# Broadcast messages are always {atom, struct}:
{:created, %Thing{}}
{:updated, %Thing{}}
{:deleted, %Thing{}}
```

| Where          | What                                        |
|----------------|---------------------------------------------|
| Context        | `subscribe_things(scope)`, `broadcast(scope, msg)` |
| LiveView mount | `if connected?(socket), do: Things.subscribe_things(scope)` |
| LiveView info  | `handle_info({:created, %Thing{}}, socket)` |

---

## Test Fixture Patterns

Fixture modules live in `test/support/fixtures/` and are named `App.PluralDomainFixtures`.

```elixir
defmodule MyApp.ThingsFixtures do
  @moduledoc """
  Test helpers for creating entities via the Things context.
  """

  def thing_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        status: :active
      })

    {:ok, thing} = MyApp.Things.create_thing(scope, attrs)
    thing
  end
end
```

### Scoped test setup

When using `--scope`, generators produce a scope fixture and wire it into tests:

```elixir
# In test setup — generators produce a setup helper
setup :register_and_log_in_user

# The setup helper creates a user and returns scope in the context
def register_and_log_in_user(%{conn: conn}) do
  user = user_fixture()
  scope = Scope.for_user(user)
  %{conn: log_in_user(conn, user), user: user, scope: scope}
end
```

### Test structure

```elixir
defmodule MyApp.ThingsTest do
  use MyApp.DataCase

  alias MyApp.Things
  import MyApp.ThingsFixtures
  import MyApp.UsersFixtures

  describe "things" do
    @invalid_attrs %{name: nil}

    test "list_things/1 returns scoped things" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      thing = thing_fixture(scope)
      _other = thing_fixture(other_scope)
      assert Things.list_things(scope) == [thing]
    end

    test "create_thing/2 with valid data" do
      scope = user_scope_fixture()
      assert {:ok, %Thing{} = thing} = Things.create_thing(scope, %{name: "test"})
      assert thing.name == "test"
    end

    test "update with wrong scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      thing = thing_fixture(scope)
      assert_raise MatchError, fn ->
        Things.update_thing(other_scope, thing, %{name: "nope"})
      end
    end
  end
end
```

### LiveView test structure

```elixir
defmodule MyAppWeb.ThingLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.ThingsFixtures

  @create_attrs %{name: "new thing"}
  @invalid_attrs %{name: nil}

  setup :register_and_log_in_user  # or appropriate auth setup

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
  end
end
```

---

## Migration Patterns

```elixir
defmodule MyApp.Repo.Migrations.CreateThings do
  use Ecto.Migration

  def change do
    create table(:things, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :status, :string, default: "active"
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :category_id, references(:categories, type: :binary_id, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:things, [:user_id])
    create index(:things, [:category_id])
  end
end
```

| Convention               | Pattern                                           |
|--------------------------|---------------------------------------------------|
| Primary key              | `primary_key: false` + `add :id, :binary_id, primary_key: true` |
| Foreign keys             | `references(:table, type: :binary_id, on_delete: ...)` |
| Owner FK `on_delete`     | `:delete_all` for user/owner ownership            |
| Optional FK `on_delete`  | `:nothing` for loose associations                 |
| Indexes                  | Always index foreign keys                         |
| Timestamps               | `timestamps(type: :utc_datetime)`                 |
