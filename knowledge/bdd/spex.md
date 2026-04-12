# BDD Specifications with Spex

## Sources
- SexySpex hex package: https://hex.pm/packages/sexy_spex
- SexySpex docs: https://hexdocs.pm/sexy_spex

---

## Overview

Spex is a BDD framework for Elixir built on ExUnit. It provides a Given-When-Then DSL for writing executable specifications that serve as both acceptance tests and living documentation. Spex files run exclusively via `mix spex`, never `mix test`.

| Concept             | Detail                                          |
|---------------------|-------------------------------------------------|
| Framework           | `SexySpex` (hex: `sexy_spex`)                   |
| Foundation          | ExUnit with `async: false`                      |
| DSL macros          | `spex`, `scenario`, `given_`, `when_`, `then_`, `and_` |
| File pattern        | `test/spex/**/*_spex.exs`                       |
| Run command         | `mix spex`                                      |
| Boundary module     | `AppSpex` in `test/spex/app_spex.ex`            |
| Shared givens       | `AppSpex.SharedGivens` in `test/spex/shared_givens.ex` |

---

## Project Structure

```
test/spex/
├── my_app_spex.ex              # Boundary definition (deps: [MyAppWeb, MyAppTest])
├── shared_givens.ex            # Reusable given steps
└── {story_id}_{story_slug}/    # One directory per story
    ├── criterion_{id}_{slug}_spex.exs
    └── criterion_{id}_{slug}_spex.exs
```

### Boundary Definition

Every project needs a boundary module that restricts spex files to the web layer:

```elixir
defmodule MyAppSpex do
  @moduledoc """
  Boundary definition for BDD specifications.

  Enforces surface-layer testing — spex files can only depend on the
  Web layer and test support, not context modules directly.
  """

  use Boundary, deps: [MyAppWeb, MyAppTest], exports: []
end
```

> For the full boundary library reference and application-wide hierarchy, see `../boundary.md`.

---

## Spex DSL Reference

### Module Setup

```elixir
defmodule MyAppSpex.UserRegistrationSpex do
  use SexySpex                    # ExUnit.Case (async: false) + DSL import
  use MyAppWeb.ConnCase           # Conn/endpoint setup for Phoenix testing
  import Phoenix.LiveViewTest     # LiveView test helpers (for LiveView specs)

  import_givens MyAppSpex.SharedGivens  # Shared step definitions
end
```

`use SexySpex` expands to:

```elixir
use ExUnit.Case, async: false
import SexySpex.DSL
require Logger
```

All standard ExUnit features remain available: `setup_all`, `setup`, `on_exit`, `assert`, `refute`, `assert_raise`.

### Macros

| Macro           | Purpose                  | Args                              |
|-----------------|--------------------------|-----------------------------------|
| `spex/2`        | Define a specification   | `name`, `do: block`               |
| `spex/3`        | Spec with options        | `name`, `opts`, `do: block`       |
| `scenario/2`    | Group steps (no context) | `name`, `do: block`               |
| `scenario/3`    | Group steps with context | `name`, `context`, `do: block`    |
| `given_/2`      | Precondition (no ctx)    | `description`, `do: block`        |
| `given_/3`      | Precondition with ctx    | `description`, `context`, `do: block` |
| `when_/2`       | Action (no context)      | `description`, `do: block`        |
| `when_/3`       | Action with context      | `description`, `context`, `do: block` |
| `then_/2`       | Assertion (no context)   | `description`, `do: block`        |
| `then_/3`       | Assertion with context   | `description`, `context`, `do: block` |
| `and_/2`        | Additional step (no ctx) | `description`, `do: block`        |
| `and_/3`        | Additional step with ctx | `description`, `context`, `do: block` |

### Spex Options

```elixir
spex "user registration",
  description: "Validates the full registration flow",
  tags: [:authentication, :registration] do
  # scenarios here
end
```

| Option          | Type              | Purpose                         |
|-----------------|-------------------|---------------------------------|
| `:description`  | `String.t()`      | Human-readable summary          |
| `:tags`         | `[atom()]`        | Categorization (printed, not filterable) |

---

## Context Flow

Context is an explicit map that threads state between steps. Each step that takes a `context` parameter receives the current context and must return an updated map.

### How Context Flows

1. ExUnit's `setup` or `setup_all` provides the initial context (e.g., `%{conn: conn}`)
2. `scenario "name", context do` initializes the scenario context from ExUnit
3. Each step receives context, modifies it with `Map.put/3`, returns the new map
4. The next step receives the updated context

### Context Rules

| Rule                                    | Example                                     |
|-----------------------------------------|---------------------------------------------|
| Return a map to update context          | `Map.put(context, :view, view)`             |
| Return non-map to keep context unchanged| `:ok` (common in `then_` steps)             |
| Use `_context` when unused              | `given_ "desc", _context do`                |
| Omit context when not needed            | `then_ "desc" do assert true end`           |

### Pattern

```elixir
scenario "user registers successfully", context do
  given_ "the registration page is loaded", context do
    {:ok, view, _html} = live(context.conn, "/users/register")
    Map.put(context, :view, view)             # returns updated context map
  end

  when_ "user submits valid credentials", context do
    html = context.view
      |> form("#registration-form", user: %{
        email: "test@example.com",
        password: "SecurePass123!"
      })
      |> render_submit()
    Map.put(context, :result_html, html)      # returns updated context map
  end

  then_ "user sees welcome message", context do
    assert render(context.view) =~ "Welcome"
    :ok                                       # non-map — context unchanged
  end
end
```

---

## Testing Patterns by Component Type

### LiveView Specs (Surface Layer)

Test what users **see and do** through `Phoenix.LiveViewTest`. Do not call context functions directly.

```elixir
defmodule MyAppSpex.UserRegistrationSpex do
  use SexySpex
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  import_givens MyAppSpex.SharedGivens

  spex "User registration",
    description: "Users can register through the registration form",
    tags: [:authentication] do

    scenario "user registers with valid data", context do
      given_ "the registration page is loaded", context do
        {:ok, view, _html} = live(context.conn, "/users/register")
        Map.put(context, :view, view)
      end

      when_ "user fills in and submits the form", context do
        html = context.view
          |> form("#registration-form", user: %{
            email: "newuser@example.com",
            password: "ValidPassword123!"
          })
          |> render_submit()
        Map.put(context, :result_html, html)
      end

      then_ "user sees success confirmation", context do
        assert render(context.view) =~ "registered successfully"
        :ok
      end
    end

    scenario "user sees validation errors for invalid input", context do
      given_ "the registration page is loaded", context do
        {:ok, view, _html} = live(context.conn, "/users/register")
        Map.put(context, :view, view)
      end

      when_ "user submits invalid data", context do
        html = context.view
          |> form("#registration-form", user: %{
            email: "not-an-email",
            password: "short"
          })
          |> render_submit()
        Map.put(context, :result_html, html)
      end

      then_ "user sees error messages", context do
        html = render(context.view)
        assert html =~ "must have the @ sign"
        assert html =~ "should be at least"
        :ok
      end
    end
  end
end
```

#### LiveView Testing Helpers

| Action                     | Code                                              |
|----------------------------|----------------------------------------------------|
| Mount LiveView             | `{:ok, view, html} = live(conn, "/path")`          |
| Submit form                | `view \|> form("#id", data: %{}) \|> render_submit()` |
| Click element              | `view \|> element("button", "Text") \|> render_click()` |
| Assert visible text        | `assert render(view) =~ "expected text"`           |
| Assert element exists      | `assert has_element?(view, "#element-id")`         |
| Assert redirect            | `assert_redirect(view, "/target")`                 |
| Assert flash (via redirect)| `{:error, {:live_redirect, %{to: path, flash: flash}}} = ...` |
| Navigate                   | `{:ok, view, html} = live(conn, "/new-path")`      |

### Controller Specs (Surface Layer)

Test HTTP requests and responses through `Phoenix.ConnTest`.

```elixir
defmodule MyAppSpex.ResourceApiSpex do
  use SexySpex
  use MyAppWeb.ConnCase

  import_givens MyAppSpex.SharedGivens

  spex "Resource API" do
    scenario "create resource with valid data", context do
      when_ "client submits valid data", context do
        conn = post(context.conn, "/api/resources", %{
          resource: %{name: "Test Resource"}
        })
        Map.put(context, :response_conn, conn)
      end

      then_ "API returns created resource", context do
        assert %{"id" => _, "name" => "Test Resource"} =
          json_response(context.response_conn, 201)
        :ok
      end
    end
  end
end
```

#### Controller Testing Helpers

| Action                | Code                                            |
|-----------------------|-------------------------------------------------|
| GET request           | `get(conn, "/path")`                            |
| POST request          | `post(conn, "/path", %{data: "value"})`         |
| PUT request           | `put(conn, "/path", %{data: "value"})`          |
| DELETE request        | `delete(conn, "/path")`                         |
| Assert HTML response  | `assert html_response(conn, 200) =~ "text"`    |
| Assert JSON response  | `assert %{"key" => val} = json_response(conn, 200)` |
| Assert redirect       | `assert redirected_to(conn) == "/path"`         |

---

## Shared Givens

Shared givens extract duplicated setup code into reusable named steps. They live in `test/spex/shared_givens.ex`.

### Definition

```elixir
defmodule MyAppSpex.SharedGivens do
  @moduledoc """
  Shared given steps for BDD specifications.

  Import in spec files with:
      import_givens MyAppSpex.SharedGivens
  """

  use SexySpex.Givens

  # Each shared given sets up state through the UI, not fixtures
  # given_ :user_registered do
  #   conn = Phoenix.ConnTest.build_conn()
  #   {:ok, view, _html} = Phoenix.LiveViewTest.live(conn, "/users/register")
  #   view
  #   |> Phoenix.LiveViewTest.form("#registration-form", user: %{
  #     email: "test#{System.unique_integer()}@example.com",
  #     password: "ValidPassword123!"
  #   })
  #   |> Phoenix.LiveViewTest.render_submit()
  #   {:ok, %{}}
  # end
end
```

### Usage in Specs

```elixir
defmodule MyAppSpex.DashboardSpex do
  use SexySpex
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  import_givens MyAppSpex.SharedGivens

  spex "Dashboard" do
    scenario "authenticated user sees dashboard" do
      given_ :user_registered          # atom syntax — references shared given
      given_ "user navigates to dashboard", context do
        {:ok, view, _html} = live(context.conn, "/dashboard")
        Map.put(context, :view, view)
      end

      then_ "dashboard content is visible", context do
        assert render(context.view) =~ "Welcome"
        :ok
      end
    end
  end
end
```

### When to Use Shared Givens

| Use shared givens for                          | Use inline givens for                     |
|------------------------------------------------|-------------------------------------------|
| Setup duplicated across multiple specs         | One-off, scenario-specific setup          |
| Generic state (user registered, logged in)     | Criterion-specific test data              |
| Commonly needed preconditions                  | Complex context that varies per scenario  |

Shared givens must set up state through the UI (LiveViewTest/ConnTest), not by calling context functions or fixtures directly.

---

## Surface Layer Testing Principles

BDD specs test **user-facing behavior**, not internal implementation. This enforces a strict boundary: specs interact with the application the same way a real user would.

| Principle                              | Correct                                         | Incorrect                               |
|----------------------------------------|-------------------------------------------------|-----------------------------------------|
| Test what users see                    | `assert render(view) =~ "Welcome"`              | `assert Users.get!(id).active?`         |
| Set up state through UI               | Submit registration form via LiveViewTest        | `Users.create_user(scope, attrs)`       |
| Assert on user feedback                | `assert html =~ "saved successfully"`           | `assert {:ok, _} = Things.create(...)` |
| Use web layer dependencies only        | `use MyAppWeb.ConnCase`                          | `alias MyApp.Users`                     |

> The `boundary` library enforces this surface-layer constraint at compile time. See `../boundary.md`.

### Path Conventions

Use plain string paths, not the `~p` sigil:

```elixir
# Correct
{:ok, view, _html} = live(context.conn, "/users/register")

# Avoid — adds Phoenix.VerifiedRoutes dependency
{:ok, view, _html} = live(context.conn, ~p"/users/register")
```

---

## Running Spex

```bash
# Run all spex files (default pattern: test/spex/**/*_spex.exs)
mix spex

# Run a specific file
mix spex test/spex/123_user_registration/criterion_456_valid_email_spex.exs

# Run with a custom pattern
mix spex --pattern "**/integration_*_spex.exs"

# Verbose output (ExUnit trace mode)
mix spex --verbose

# Manual mode — pause at each step, IEx debugging
mix spex --manual

# Custom timeout (default: 60s)
mix spex --timeout 120000
```

| Flag             | Short | Purpose                                    |
|------------------|-------|--------------------------------------------|
| `--pattern`      |       | Glob pattern for spex files                |
| `--verbose`      | `-v`  | Trace mode with detailed output            |
| `--manual`       | `-m`  | Interactive step-by-step execution         |
| `--timeout`      |       | Test timeout in milliseconds               |
| `--help`         | `-h`  | Show usage information                     |

### Manual Mode

Manual mode pauses before each step and offers:
- **[ENTER]** — continue executing the step
- **[iex]** — drop into a debug shell (evaluate arbitrary Elixir, type `exit` to return)
- **[q]** — quit test execution

---

## ExUnit Integration

Since Spex is built on ExUnit, all standard callbacks and assertions are available.

### Setup Callbacks

```elixir
defmodule MyAppSpex.FeatureSpex do
  use SexySpex
  use MyAppWeb.ConnCase

  # Runs once before all spex in this module
  setup_all do
    {:ok, %{app_config: load_config()}}
  end

  # Runs before each spex — ConnCase already provides :conn
  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "text/html")}
  end

  # Cleanup after each spex
  setup do
    on_exit(fn -> cleanup_temp_files() end)
    :ok
  end
end
```

### Assertions

All ExUnit assertions work in any step:

```elixir
given_ "data is set up", context do
  result = some_setup()
  assert result != nil                    # basic assertion
  assert %{id: _} = result               # pattern match assertion
  refute result.archived?                 # negative assertion
  Map.put(context, :result, result)
end

when_ "invalid action attempted", context do
  assert_raise ArgumentError, ~r/required/, fn ->
    invalid_operation()
  end
  context
end
```

### Failure Behavior

When an assertion fails in any step:
1. The step raises an `ExUnit.AssertionError`
2. The scenario catches it and reports via `SexySpex.Reporter.scenario_failed/2`
3. The spex catches it and reports via `SexySpex.Reporter.spex_failed/2`
4. The error re-raises with full stacktrace
5. ExUnit marks the test as failed

---

## Output Format

Spex produces structured output with visual markers:

```
🎯 Running Spex: User registration
==================================================
   Validates the full registration flow
   Tags: #authentication #registration

  📋 Scenario: user registers with valid data
    Given: the registration page is loaded
    When: user fills in and submits the form
    Then: user sees success confirmation
  ✅ Scenario passed: user registers with valid data

  📋 Scenario: user sees validation errors for invalid input
    Given: the registration page is loaded
    When: user submits invalid data
    Then: user sees error messages
  ✅ Scenario passed: user sees validation errors for invalid input

✅ Spex completed: User registration
```

---

## Complete Example: CRUD LiveView Spec

```elixir
defmodule MyAppSpex.ThingManagementSpex do
  use SexySpex
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  import_givens MyAppSpex.SharedGivens

  # ConnCase setup provides :conn with authenticated user

  spex "Thing management",
    description: "Users can create, view, edit, and delete things",
    tags: [:things, :crud] do

    scenario "user creates a new thing", context do
      given_ "user navigates to the new thing page", context do
        {:ok, view, _html} = live(context.conn, "/things/new")
        Map.put(context, :view, view)
      end

      when_ "user submits a valid thing", context do
        html = context.view
          |> form("#thing-form", thing: %{name: "My Thing"})
          |> render_submit()
        Map.put(context, :result_html, html)
      end

      then_ "user sees the thing was created", context do
        assert render(context.view) =~ "Thing created successfully"
        :ok
      end
    end

    scenario "user sees validation errors", context do
      given_ "user navigates to the new thing page", context do
        {:ok, view, _html} = live(context.conn, "/things/new")
        Map.put(context, :view, view)
      end

      when_ "user submits without a name", context do
        html = context.view
          |> form("#thing-form", thing: %{name: ""})
          |> render_submit()
        Map.put(context, :result_html, html)
      end

      then_ "user sees a validation error", context do
        assert render(context.view) =~ "can't be blank"
        :ok
      end
    end

    scenario "user lists existing things", context do
      given_ "user navigates to the things index", context do
        {:ok, view, html} = live(context.conn, "/things")
        context
        |> Map.put(:view, view)
        |> Map.put(:html, html)
      end

      then_ "user sees the listing page", context do
        assert context.html =~ "Listing Things"
        :ok
      end
    end

    scenario "user deletes a thing", context do
      given_ "a thing exists and user is on the index page", context do
        # Create via UI first (surface layer only)
        {:ok, form_view, _html} = live(context.conn, "/things/new")
        form_view
        |> form("#thing-form", thing: %{name: "To Delete"})
        |> render_submit()

        {:ok, view, _html} = live(context.conn, "/things")
        Map.put(context, :view, view)
      end

      when_ "user clicks delete and confirms", context do
        context.view
        |> element("a", "Delete")
        |> render_click()
        context
      end

      then_ "the thing is removed from the list", context do
        refute render(context.view) =~ "To Delete"
        :ok
      end
    end
  end
end
```

---

## Configuration

Application-level config for SexySpex behavior:

```elixir
# config/test.exs
config :sexy_spex,
  manual_mode: false,    # Enable interactive step-by-step execution
  step_delay: 0          # Milliseconds to pause between steps (useful for visual testing)
```
