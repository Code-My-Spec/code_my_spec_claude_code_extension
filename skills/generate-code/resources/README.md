# Code Generation Resources

Reference materials for AI-assisted Phoenix LiveView code generation.
Extracted from official documentation — each file lists source URLs at the top.

## When to read what

| Building...                        | Read                                      |
|------------------------------------|-------------------------------------------|
| ExUnit test module (setup, tags)   | `exunit/core.md`                          |
| Assertions in any test             | `exunit/assertions.md`                    |
| Setup blocks, fixtures, on_exit    | `exunit/callbacks.md`                     |
| Capturing log or IO output         | `exunit/capture.md`                       |

## Target stack

- Phoenix 1.8-rc
- Phoenix LiveView 1.1-rc
- DaisyUI 5
- Tailwind CSS 4

## File index

```
resources/
├── README.md                 ← you are here
└── exunit/
    ├── core.md               # ExUnit.Case, describe, test, tags, async, parameterize, doctest
    ├── assertions.md         # assert, refute, assert_raise, assert_receive, flunk, catch_*
    ├── callbacks.md          # setup, setup_all, on_exit, start_supervised, fixtures, DataCase/ConnCase
    └── capture.md            # CaptureLog, CaptureIO, with_log, with_io
```
