# Boundary Library — Context Isolation & Dependency Rules

## Sources
- Boundary hex package: https://hex.pm/packages/boundary
- Boundary docs: https://hexdocs.pm/boundary
- Boundary GitHub: https://github.com/sasa1977/boundary

---

## Overview

Boundary is a compile-time dependency enforcement library for Elixir. It prevents modules from reaching across bounded context boundaries — e.g., calling another context's repo directly, or importing a context module from a BDD spec.

| Concept         | Detail                                                    |
|-----------------|-----------------------------------------------------------|
| Library         | `boundary` (hex: `boundary`)                              |
| Enforcement     | Compile-time via custom Mix compiler                      |
| Declaration     | `use Boundary, deps: [...], exports: [...]`               |
| Violation       | Compile warning (CI-breaking with `--warnings-as-errors`) |
| Granularity     | Module-level — every module belongs to exactly one boundary |

---

## Setup

### 1. Add dependency

```elixir
# mix.exs
defp deps do
  [
    {:boundary, "~> 0.10", runtime: false}
  ]
end
```

### 2. Add compiler

```elixir
# mix.exs
def project do
  [
    compilers: [:boundary] ++ Mix.compilers(),
    # ...
  ]
end
```

### 3. Configure boundary check options

```elixir
# mix.exs — inside project/0
boundary: [
  default: [
    check: [
      aliases: true,
      deps: true,
      exports: true
    ]
  ]
]
```

---

## Boundary Hierarchy

```
┌──────────────────────────────────────────────────┐
│  Application Boundary (MyApp)                    │
│  ┌──────────────────────────────────────────┐    │
│  │  Domain Contexts                         │    │
│  │  Users, Accounts, Infrastructure, ...    │    │
│  └──────────────────────────────────────────┘    │
└──────────────────────────────────────────────────┘
         ▲
         │ deps: [MyApp]
┌──────────────────────────────────────────────────┐
│  Web Boundary (MyAppWeb)                         │
│  LiveViews, Controllers, Router, Components      │
└──────────────────────────────────────────────────┘
         ▲                          ▲
         │ deps: [MyAppWeb,         │ deps: [MyAppWeb,
         │        MyAppTest]        │        MyAppTest]
┌────────────────────┐    ┌────────────────────────┐
│  MyAppSpex         │    │  MyAppTest             │
│  BDD specs only    │    │  Fixtures, DataCase,   │
│  (compile-checked) │    │  ConnCase              │
│                    │    │  (check disabled)      │
└────────────────────┘    └────────────────────────┘
```

| Boundary     | Purpose                                      | `check`                          |
|--------------|----------------------------------------------|----------------------------------|
| `MyApp`      | Domain contexts (Users, Accounts, etc.)      | Strict — deps/exports enforced   |
| `MyAppWeb`   | Web layer (LiveViews, controllers, router)   | Strict — deps on `MyApp` only   |
| `MyAppTest`  | All test support (fixtures, DataCase, ConnCase) | Disabled (`in: false, out: false`) |
| `MyAppSpex`  | BDD specs only                               | Strict — `deps: [MyAppWeb, MyAppTest]` |

---

## Application Boundary

The top-level application module declares all domain contexts as exports:

```elixir
defmodule MyApp do
  use Boundary,
    deps: [],
    exports: [
      Users,
      Accounts,
      Infrastructure,
      Invitations
      # add every public context here
    ]
end
```

**Rule:** Every domain context that the web layer needs to call must appear in `exports`.

---

## Context Boundary Declarations

Each context declares its own boundary with `deps` and `exports`:

```elixir
defmodule MyApp.Users do
  use Boundary,
    deps: [MyApp.Infrastructure],
    exports: [User, Scope]

  # ... context functions
end
```

### Dependency rules

| Context          | `deps`                                  | Rationale                                 |
|------------------|-----------------------------------------|-------------------------------------------|
| Infrastructure   | `[]`                                    | Leaf — no domain deps, only Ecto/stdlib   |
| Users            | `[MyApp.Infrastructure]`                | Needs shared infra (Repo, Mailer, etc.)   |
| Accounts         | `[MyApp.Infrastructure, MyApp.Users]`   | Depends on Users for ownership            |
| Invitations      | `[MyApp.Infrastructure, MyApp.Users, MyApp.Accounts]` | Cross-domain coordination |

**Rules:**
- Infrastructure has no domain deps — it is the leaf layer
- Domain contexts dep on Infrastructure, not on Repo directly
- Cross-domain deps are explicit and intentional
- Circular deps are forbidden (boundary enforces this at compile time)

### Export rules

| What               | Exported? | Rationale                                            |
|--------------------|-----------|------------------------------------------------------|
| Schemas (`User`)   | Yes       | Other contexts/web need the struct type              |
| Scope              | Yes       | Threaded through all layers                          |
| Repos              | **Never** | Private implementation detail — always behind context facade |
| Notifiers/Mailers  | **Never** | Internal side effects — context functions trigger them |
| Query modules      | **Never** | Internal query builders — context functions wrap them |

### Real examples

```elixir
defmodule MyApp.Infrastructure do
  use Boundary, deps: [], exports: [Repo, Mailer]
end

defmodule MyApp.Users do
  use Boundary,
    deps: [MyApp.Infrastructure],
    exports: [User, Scope]
end

defmodule MyApp.Accounts do
  use Boundary,
    deps: [MyApp.Infrastructure, MyApp.Users],
    exports: [Account, Membership]
end

defmodule MyApp.Invitations do
  use Boundary,
    deps: [MyApp.Infrastructure, MyApp.Users, MyApp.Accounts],
    exports: [Invitation]
end
```

---

## Web Layer Boundary

```elixir
defmodule MyAppWeb do
  use Boundary, deps: [MyApp], exports: []
end
```

| Rule                                   | Detail                                           |
|----------------------------------------|--------------------------------------------------|
| Web depends on `MyApp` only            | All domain access goes through context facades   |
| Web never deps on Infrastructure       | No direct Repo/Mailer calls from LiveViews       |
| Contexts never dep on Web              | Domain layer has no knowledge of HTTP/LiveView   |
| Web exports nothing                    | No other boundary depends on web internals       |

### What this prevents

```elixir
# VIOLATION — LiveView calling Repo directly
defmodule MyAppWeb.ThingLive.Index do
  alias MyApp.Repo              # ← boundary violation
  alias MyApp.Things.Thing
  def mount(_, _, socket) do
    things = Repo.all(Thing)    # ← should call Things.list_things(scope)
  end
end

# VIOLATION — LiveView importing internal schema module not in exports
defmodule MyAppWeb.ThingLive.Form do
  alias MyApp.Things.ThingQuery  # ← not exported, boundary violation
end
```

---

## Repository Pattern & Privacy

Repos are private implementation details. Contexts are the only modules that touch Repo.

| Caller               | Can access Repo? | Can access Schemas? | Can call Context functions? |
|----------------------|------------------|---------------------|-----------------------------|
| Context (same)       | Yes              | Yes                 | Yes (own functions)         |
| Context (other)      | **No**           | Exported only       | Yes (public API)            |
| LiveView/Controller  | **No**           | Exported only       | Yes (public API)            |
| Test (DataCase)      | **No** (use fixtures) | Yes (via imports) | Yes                     |
| Spex (BDD)           | **No**           | **No**              | **No** (web layer only)     |

### Correct pattern

```elixir
# Context owns the repo call
defmodule MyApp.Things do
  alias MyApp.Repo
  alias MyApp.Things.Thing

  def list_things(%Scope{} = scope) do
    Repo.all_by(Thing, user_id: scope.user_id)
  end
end

# LiveView calls context, never Repo
defmodule MyAppWeb.ThingLive.Index do
  alias MyApp.Things

  def mount(_, _, socket) do
    things = Things.list_things(socket.assigns.scope)
    {:ok, stream(socket, :things, things)}
  end
end
```

---

## Test Boundary

Test support modules (DataCase, ConnCase, fixtures) live under `MyAppTest` with boundary checking disabled:

```elixir
defmodule MyAppTest do
  use Boundary, check: [in: false, out: false], exports: []
end
```

| Setting          | Meaning                                                   |
|------------------|-----------------------------------------------------------|
| `in: false`      | Other boundaries can depend on test modules freely        |
| `out: false`     | Test modules can call anything (contexts, repos, schemas) |
| `exports: []`    | No formal export list needed                              |

### Why disabled?

Test support code (fixtures, DataCase, ConnCase) needs to:
- Call context functions to create test data
- Access schemas for pattern matching
- Set up database state via Ecto.Sandbox

This is acceptable because test support code never ships to production.

### Convention: DataCase vs ConnCase

No separate MyAppWebTest boundary is needed. The existing convention handles separation:

| Test type      | Uses                   | Tests                          |
|----------------|------------------------|--------------------------------|
| Context tests  | `use MyApp.DataCase`   | Context functions, schemas     |
| LiveView tests | `use MyAppWeb.ConnCase` | Routes, LiveViews, controllers |
| BDD specs      | `use MyAppWeb.ConnCase` | User-facing behavior only      |

---

## BDD/Spex Boundary

The spex boundary is the strictest — it can only access the web layer and test support:

```elixir
defmodule MyAppSpex do
  use Boundary, deps: [MyAppWeb, MyAppTest], exports: []
end
```

### What this enforces

| Action                                      | Allowed? | Why                                          |
|---------------------------------------------|----------|----------------------------------------------|
| `use MyAppWeb.ConnCase`                     | Yes      | Web layer dependency                         |
| `import Phoenix.LiveViewTest`               | Yes      | LiveView testing through web                 |
| `live(conn, "/things")`                     | Yes      | Testing through the surface layer            |
| `alias MyApp.Things`                        | **No**   | Direct context access — boundary violation   |
| `MyApp.Things.create_thing(scope, attrs)`   | **No**   | Bypasses web layer — boundary violation      |
| `import MyApp.ThingsFixtures`               | **No**   | Fixture access is for unit tests, not spex   |
| `alias MyApp.Repo`                          | **No**   | Direct repo access — boundary violation      |

### MyAppTest vs MyAppSpex access comparison

| Capability                          | MyAppTest (fixtures, DataCase) | MyAppSpex (BDD specs)          |
|-------------------------------------|-------------------------------|--------------------------------|
| Call context functions              | Yes                           | **No**                         |
| Use fixtures                        | Yes                           | **No**                         |
| Access Repo                         | Yes                           | **No**                         |
| Access schemas directly             | Yes                           | **No**                         |
| Mount LiveViews                     | Yes (via ConnCase)            | Yes (via ConnCase)             |
| Submit forms via LiveViewTest       | Yes                           | Yes                            |
| Make HTTP requests via ConnTest     | Yes                           | Yes                            |
| Boundary checking                   | Disabled                      | **Enforced at compile time**   |

---

## Rules for LLM Agents

When generating code, follow these rules to avoid boundary violations.

### Do / Don't table

| Generating...         | Do                                                  | Don't                                                |
|-----------------------|-----------------------------------------------------|------------------------------------------------------|
| Context module        | `use Boundary, deps: [...], exports: [...]`         | Omit boundary declaration                            |
| Context deps          | Only dep on Infrastructure + explicitly needed contexts | Dep on `MyAppWeb` or unrelated contexts           |
| Context exports       | Export schemas and Scope                            | Export Repo, Notifier, Query, or internal modules    |
| Repo call             | Call from within the owning context only            | Call from LiveView, controller, or another context   |
| Schema alias          | Alias from owning context or if exported            | Alias an unexported schema from another context      |
| LiveView              | Call context public API (`Things.list_things/1`)    | Alias Repo or call Repo directly                     |
| LiveView deps         | Only `alias MyApp.{ContextName}`                   | `alias MyApp.Infrastructure.Repo`                    |
| Context test          | `use MyApp.DataCase`, import fixtures               | `use MyAppWeb.ConnCase` for pure context tests       |
| LiveView test         | `use MyAppWeb.ConnCase`, `import Phoenix.LiveViewTest` | Call context functions to verify side effects      |
| BDD spec (spex)       | `use MyAppWeb.ConnCase`, test through UI only       | `alias MyApp.Things`, `import MyApp.ThingsFixtures`  |
| BDD spec setup        | Set up state via form submissions / UI actions      | Call `Things.create_thing(scope, attrs)` directly    |
| BDD spec assertions   | `assert render(view) =~ "text"`                    | `assert Things.get_thing!(scope, id).name == "x"`   |
| New boundary          | Declare with explicit deps and exports              | Use `check: [in: false, out: false]` unless test support |

### Checklist before generating

1. **Which boundary does this module belong to?** Match namespace: `MyApp.*` → MyApp, `MyAppWeb.*` → MyAppWeb, `MyAppTest.*` → MyAppTest, `MyAppSpex.*` → MyAppSpex
2. **Does the context declare `use Boundary`?** Every context needs deps and exports
3. **Are repo calls inside the owning context?** Repo is never called from outside
4. **Are exports minimal?** Only schemas and Scope — never Repo, Notifier, Query
5. **Do spex files only use web-layer APIs?** No context aliases, no fixture imports, no repo access
