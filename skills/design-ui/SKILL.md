---
name: design-ui
description: Interview the user to establish a design system. Produces a self-contained HTML file with DaisyUI CDN, theme switcher, and live preview of colors, typography, and components.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task design_ui ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
