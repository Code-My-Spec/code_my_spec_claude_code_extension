# ExUnit Callbacks, Setup & Fixtures

## Sources
- https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html

---

## setup — runs before each test

### Block form

```elixir
setup do
  user = user_fixture()
  scope = Scope.for_user(user)
  %{user: user, scope: scope}
end
```

### Named function form

```elixir
setup :create_user

defp create_user(_context) do
  user = user_fixture()
  %{user: user, scope: Scope.for_user(user)}
end
```

### List of functions

```elixir
setup [:create_user, :create_thing]

defp create_user(_context) do
  user = user_fixture()
  %{user: user, scope: Scope.for_user(user)}
end

defp create_thing(%{scope: scope}) do
  %{thing: thing_fixture(scope)}
end
```

### External module function

```elixir
setup {MyApp.TestHelpers, :setup_sandbox}
```

### With context

```elixir
setup %{conn: conn} = context do
  if context[:logged_in] do
    user = user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  else
    :ok
  end
end
```

### Return values

```elixir
# Return map or keyword list — merged into context
setup do
  %{key: "value"}
end

# Return :ok — no context update
setup do
  SomeService.start()
  :ok
end

# Return {:ok, map} — also merged into context
setup do
  {:ok, %{key: "value"}}
end
```

---

## setup inside describe

Each `describe` block can have its own setup. It runs in addition to module-level setup.

```elixir
# Module-level setup runs first
setup :create_user

describe "admin operations" do
  # This setup runs after module-level setup
  setup %{user: user} do
    {:ok, admin} = Users.promote_to_admin(user)
    %{admin: admin}
  end

  test "can delete others", %{admin: admin} do
    assert Admin.can_delete?(admin)
  end
end
```

---

## setup_all — runs once before all tests

Runs in a dedicated process separate from test processes. Context values are shared across all tests (read-only).

```elixir
setup_all do
  {:ok, pid} = MyApp.CacheServer.start_link()
  on_exit(fn -> GenServer.stop(pid) end)
  %{cache: pid}
end
```

### Named function form

```elixir
setup_all :start_cache

defp start_cache(_context) do
  {:ok, pid} = MyApp.CacheServer.start_link()
  on_exit(fn -> GenServer.stop(pid) end)
  %{cache: pid}
end
```

### Important: setup_all values are immutable

Values from `setup_all` are copied into each test context. Modifying them in `setup` or a test does not affect other tests.

---

## on_exit — cleanup after test or suite

### In setup (runs after each test)

```elixir
setup do
  File.write!("tmp/fixture.json", "{}")
  on_exit(fn -> File.rm!("tmp/fixture.json") end)
  :ok
end
```

### Named handlers (can be overridden)

```elixir
setup do
  on_exit(:cleanup_db, fn -> Repo.delete_all(Thing) end)
  :ok
end

test "skip cleanup for this test" do
  on_exit(:cleanup_db, fn -> :ok end)  # override with no-op
  # ...
end
```

### In setup_all (runs after all tests in module)

```elixir
setup_all do
  Database.create_table_for(__MODULE__)
  on_exit(fn -> Database.drop_table_for(__MODULE__) end)
  :ok
end
```

### Execution order

`on_exit` callbacks execute in **reverse registration order** (last registered runs first).

---

## start_supervised — managed child processes

Starts a process under the test supervisor. Automatically stopped and verified before next test.

```elixir
# Module child spec
{:ok, pid} = start_supervised(MyGenServer)

# With init arg
{:ok, pid} = start_supervised({MyGenServer, initial_state: %{}})

# With options
{:ok, pid} = start_supervised({MyWorker, []}, restart: :temporary)

# Bang version — returns pid directly, raises on failure
pid = start_supervised!(MyGenServer)
```

### stop_supervised

```elixir
{:ok, _pid} = start_supervised(MyServer)
:ok = stop_supervised(MyServer)

# Bang version — raises if not found
stop_supervised!(MyServer)
```

### start_link_supervised!

Like `start_supervised!` but links to test process — crashes propagate as test failures.

```elixir
pid = start_link_supervised!(MyGenServer)
```

---

## Fixture Patterns

### Fixture module

```elixir
# test/support/fixtures/things_fixtures.ex
defmodule MyApp.ThingsFixtures do
  @moduledoc """
  Test helpers for creating Things entities.
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

### Scope fixture

```elixir
# test/support/fixtures/users_fixtures.ex
defmodule MyApp.UsersFixtures do
  def user_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        email: "user#{System.unique_integer()}@example.com",
        password: "hello world 123"
      })

    {:ok, user} = MyApp.Users.register_user(attrs)
    user
  end

  def user_scope_fixture(attrs \\ %{}) do
    user = user_fixture(attrs)
    MyApp.Users.Scope.for_user(user)
  end
end
```

### Auth setup helper (ConnCase)

```elixir
# test/support/conn_case.ex
def register_and_log_in_user(%{conn: conn}) do
  user = MyApp.UsersFixtures.user_fixture()
  scope = MyApp.Users.Scope.for_user(user)
  %{conn: log_in_user(conn, user), user: user, scope: scope}
end
```

### Using fixtures in tests

```elixir
defmodule MyApp.ThingsTest do
  use MyApp.DataCase

  alias MyApp.Things
  import MyApp.ThingsFixtures
  import MyApp.UsersFixtures

  setup do
    scope = user_scope_fixture()
    %{scope: scope}
  end

  describe "things" do
    test "list_things/1 returns scoped things", %{scope: scope} do
      thing = thing_fixture(scope)
      other_scope = user_scope_fixture()
      _other = thing_fixture(other_scope)
      assert Things.list_things(scope) == [thing]
    end

    test "create_thing/2 with valid data", %{scope: scope} do
      assert {:ok, %Things.Thing{} = thing} =
               Things.create_thing(scope, %{name: "test"})
      assert thing.name == "test"
    end
  end
end
```

---

## DataCase vs ConnCase

| Test type          | Use            | Provides                                   |
|--------------------|----------------|--------------------------------------------|
| Context / Schema   | `MyApp.DataCase`  | Ecto sandbox, `errors_on/1`             |
| LiveView / Controller | `MyAppWeb.ConnCase` | `build_conn()`, auth helpers, sandbox |

### DataCase template

```elixir
defmodule MyApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import MyApp.DataCase
    end
  end

  setup tags do
    MyApp.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MyApp.Repo,
      shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
```

### ConnCase template

```elixir
defmodule MyAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint MyAppWeb.Endpoint
      use MyAppWeb, :verified_routes
      import Plug.Conn
      import Phoenix.ConnTest
      import MyAppWeb.ConnCase
    end
  end

  setup tags do
    MyApp.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
```

---

## Complete Setup Chaining Example

```elixir
defmodule MyAppWeb.ThingLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.ThingsFixtures

  # 1. ConnCase setup: sandbox + build_conn
  # 2. Module setup: auth
  setup :register_and_log_in_user

  # 3. Describe setup: create test data
  describe "Index" do
    setup %{scope: scope} do
      thing = thing_fixture(scope)
      %{thing: thing}
    end

    # Context has: conn, user, scope, thing
    test "lists things", %{conn: conn, thing: thing} do
      {:ok, _live, html} = live(conn, ~p"/things")
      assert html =~ thing.name
    end
  end
end
```
