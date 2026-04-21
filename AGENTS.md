# CodeMySpec Agent Context

You are working inside a project managed by CodeMySpec. This file tells you where to find what you need.

## Project Resources (in working directory)

| Need | Location |
|---|---|
| What a module should do | `.code_my_spec/spec/<module_path>.spec.md` |
| Coding standards by component type | `.code_my_spec/rules/<type>_design.md` |
| Test conventions by component type | `.code_my_spec/rules/<type>_test.md` |
| Component graph and dependencies | `.code_my_spec/architecture/overview.md` |
| Technology decisions & rationale | `.code_my_spec/architecture/decisions.md` (index) → `.code_my_spec/architecture/decisions/` |
| Project-specific knowledge | `.code_my_spec/knowledge/{topic}/` |
| Framework knowledge (LiveView, DaisyUI, etc.) | `.code_my_spec/plugin_knowledge/` |
| Implementation status checklists | `.code_my_spec/status/` |
| Design system | `.code_my_spec/design/design_system.html` |
| Known issues | `.code_my_spec/issues/` |

Spec paths mirror the Elixir namespace: `MyApp.Accounts.User` → `.code_my_spec/spec/my_app/accounts/user.spec.md`

## Framework Knowledge (via plugin_knowledge/)

Read `.code_my_spec/plugin_knowledge/README.md` for the full index. Quick reference:

| Working on... | Read |
|---|---|
| Phoenix contexts, schemas, conventions | `plugin_knowledge/conventions.md` |
| LiveView mount/events/streams | `plugin_knowledge/liveview/patterns.md` |
| Function components (attr/slot) | `plugin_knowledge/liveview/core_components.md` |
| Forms and changesets | `plugin_knowledge/liveview/forms.md` |
| LiveView/component tests | `plugin_knowledge/liveview/testing.md` |
| HEEx templates | `plugin_knowledge/heex/syntax.md` |
| Styling and layout | `plugin_knowledge/ui/tailwind.md`, `plugin_knowledge/ui/daisyui.md` |
| BDD specs (Given/When/Then) | `plugin_knowledge/bdd/spex.md` |

## How to use

1. Read the prompt file you were given first — it has your specific task
2. Read the spec for the component you're working on
3. Read the rules for that component type
4. Check plugin_knowledge/ for relevant framework guides
5. Check knowledge/ for project-specific research
6. Research similar components in the codebase for patterns
