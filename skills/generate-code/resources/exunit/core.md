# ExUnit Core

## Sources
- https://hexdocs.pm/ex_unit/ExUnit.html
- https://hexdocs.pm/ex_unit/ExUnit.Case.html
- https://hexdocs.pm/ex_unit/ExUnit.DocTest.html

---

## Setup

```elixir
# test/test_helper.exs
ExUnit.start()
```

Tests matching `*_test.exs` in the `test` directory are auto-discovered by `mix test`.

---

## Test Module

```elixir
defmodule MyApp.ThingsTest do
  use ExUnit.Case, async: true

  test "basic assertion" do
    assert 1 + 1 == 2
  end
end
```

### `use ExUnit.Case` options

| Option          | Description                                        | Default |
|-----------------|----------------------------------------------------|---------|
| `:async`        | Run concurrently with other async modules          | `false` |
| `:group`        | Group name — same-group modules don't run concurrently | `nil` |
| `:register`     | Register with ExUnit server                        | `true`  |
| `:parameterize` | List of maps — runs all tests per parameter set    | `nil`   |

Using `ExUnit.Case` auto-imports: `ExUnit.Assertions`, `ExUnit.Callbacks`, `ExUnit.DocTest`.

---

## test macro

### With body

```elixir
test "descriptive name", %{conn: conn, scope: scope} do
  # second arg pattern-matches the test context
  assert conn != nil
end
```

### Stub (always fails with "Not implemented")

```elixir
test "todo test"
```

---

## describe blocks

Group related tests under a shared prefix. Supports local `setup` inside the block. Cannot be nested.

```elixir
describe "create_thing/2" do
  setup [:create_scope]

  test "with valid attrs", %{scope: scope} do
    assert {:ok, %Thing{}} = Things.create_thing(scope, %{name: "test"})
  end

  test "with invalid attrs", %{scope: scope} do
    assert {:error, %Ecto.Changeset{}} = Things.create_thing(scope, %{name: nil})
  end
end
```

---

## Tags

### Per-test

```elixir
@tag :slow
@tag timeout: 120_000
test "expensive operation" do
  # ...
end
```

### Per-describe

```elixir
@describetag :integration
describe "external API" do
  # all tests here tagged :integration
end
```

### Per-module

```elixir
@moduletag :acceptance
```

### Behavior-modifying tags

| Tag            | Effect                                             | Example                    |
|----------------|----------------------------------------------------|-----------------------------|
| `:capture_log`  | Suppress log output unless test fails              | `@tag capture_log: true`   |
| `:skip`         | Skip test with reason                              | `@tag skip: "pending API"` |
| `:timeout`      | Override default 60s timeout                       | `@tag timeout: 120_000`    |
| `:tmp_dir`      | Create unique temp directory in context            | `@tag :tmp_dir`            |

### Filtering tests by tag

```bash
# Command line
mix test --only slow
mix test --exclude slow
mix test --include external:true

# In test_helper.exs
ExUnit.configure(exclude: [external: true])
```

---

## Async & Concurrency

```elixir
# Tests in THIS module run concurrently with OTHER async modules
# Tests within the same module are always sequential
use ExUnit.Case, async: true
```

### Groups (v1.18+)

```elixir
# Modules in same group don't run concurrently even with async: true
use ExUnit.Case, async: true, group: :database
```

---

## Parameterized Tests (v1.18+)

```elixir
use ExUnit.Case,
  async: true,
  parameterize: [
    %{store: :ets},
    %{store: :dets}
  ]

test "stores values", %{store: store} do
  assert MyApp.Store.put(store, :key, :value) == :ok
end
```

Each parameter set runs as a separate concurrent group when async is true.

---

## DocTest

```elixir
defmodule MyApp.HelperTest do
  use ExUnit.Case
  doctest MyApp.Helper
  doctest MyApp.Helper, except: [:moduledoc, format: 1]
  doctest MyApp.Helper, only: [parse: 2]
end
```

### From markdown files

```elixir
doctest_file "README.md"
```

### Options

| Option          | Description                                      |
|-----------------|--------------------------------------------------|
| `:except`       | Exclude `{function, arity}` tuples or `:moduledoc` |
| `:only`         | Include only listed functions                    |
| `:import`       | Allow unqualified function calls                 |
| `:tags`         | Tags applied to all generated doctests           |

---

## ExUnit Configuration

```elixir
ExUnit.start(
  capture_log: true,           # suppress logs unless failure
  max_cases: 8,                # parallel module limit
  seed: 0,                     # disable randomization
  trace: true,                 # verbose output (sets max_cases: 1)
  max_failures: 1,             # stop after first failure
  slowest: 10,                 # show 10 slowest tests
  timeout: 60_000,             # default test timeout
  assert_receive_timeout: 100  # default for assert_receive
)
```

---

## Process Architecture

1. `setup_all` callbacks run sequentially in a dedicated process
2. Each test spawns its own process; `setup` callbacks run first in that process
3. After test exits, `on_exit` callbacks run in reverse order in a separate process
