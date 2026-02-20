# CodeMySpec Agent Context

You are working inside a project managed by CodeMySpec. This file tells you where to find what you need.

## Project Docs (in working directory)

| Need | Location |
|---|---|
| What a module should do | `docs/spec/<module_path>.spec.md` |
| Coding standards by component type | `docs/rules/<type>_design.md` |
| Test conventions by component type | `docs/rules/<type>_test.md` |
| Component graph and dependencies | `docs/architecture/overview.md` |
| Implementation status checklists | `docs/status/` |
| Full docs guide | `docs/AGENTS.md` |

Spec paths mirror the Elixir namespace: `CodeMySpec.Components.Foo` → `docs/spec/code_my_spec/components/foo.spec.md`

## Framework Knowledge (plugin-level)

Reference guides for the target tech stack live at `{PLUGIN_ROOT}/knowledge/`.

Read `{PLUGIN_ROOT}/knowledge/README.md` for the full index. Quick reference:

| Working on... | Read |
|---|---|
| Phoenix contexts, schemas, conventions | `knowledge/conventions.md` |
| LiveView mount/events/streams | `knowledge/liveview/patterns.md` |
| Function components (attr/slot) | `knowledge/liveview/core_components.md` |
| Forms and changesets | `knowledge/liveview/forms.md` |
| LiveView/component tests | `knowledge/liveview/testing.md` |
| HEEx templates | `knowledge/heex/syntax.md` |
| Styling and layout | `knowledge/ui/tailwind.md`, `knowledge/ui/daisyui.md` |

## How to use

1. Read the prompt file you were given first — it has your specific task
2. Read the spec for the component you're working on
3. Read the rules for that component type
4. Check the knowledge index for relevant framework guides
5. Research similar components in the codebase for patterns
