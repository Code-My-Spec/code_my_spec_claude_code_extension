# Code Generation Resources

Reference materials for AI-assisted Phoenix LiveView code generation.
Extracted from official documentation — each file lists source URLs at the top.

## When to read what

| Building...                        | Read                                      |
|------------------------------------|-------------------------------------------|
| A new LiveView module              | `liveview/patterns.md`                    |
| Function components / core_components | `liveview/core_components.md`          |
| A form (create, edit, settings)    | `liveview/forms.md`                       |
| LiveView or LiveComponent tests    | `liveview/testing.md`                     |
| Any HEEx template                  | `heex/syntax.md`                          |
| UI layout or styling               | `ui/tailwind.md` then `ui/daisyui.md`    |
| A table, modal, card, or list      | `ui/daisyui.md` + `liveview/patterns.md` |
| Context, schema, or test scaffold  | `conventions.md`                          |
| BDD specs (Given/When/Then)        | `bdd/spex.md`                             |
| Bounded context isolation, dep rules | `boundary.md`                             |

## Target stack

- Phoenix 1.8-rc
- Phoenix LiveView 1.1-rc
- DaisyUI 5
- Tailwind CSS 4

## File index

```
knowledge/
├── README.md                 ← you are here
├── boundary.md              # Boundary library, context isolation, dep/export rules
├── conventions.md            # Layered architecture, naming, scope, contexts, schemas, tests
├── liveview/
│   ├── patterns.md           # mount, handle_event, handle_params, streams, assign_async, JS commands
│   ├── core_components.md    # attr/slot macros, function components, render_slot, :global
│   ├── forms.md              # to_form, phx-change/submit, validation, changesets
│   └── testing.md            # LiveViewTest: mount, events, forms, navigation, uploads, assertions
├── ui/
│   ├── daisyui.md            # Component classes, theme system, semantic colors
│   └── tailwind.md           # Layout, spacing, responsive breakpoints, flex/grid
├── heex/
│   └── syntax.md             # ~H sigil, :for/:if/:let, phx- bindings, change tracking
└── bdd/
    └── spex.md               # SexySpex DSL, Given/When/Then, context flow, shared givens, mix spex
```
