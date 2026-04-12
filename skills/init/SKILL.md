---
name: init
description: Run project initialization checklist. Checks Elixir, Phoenix, PostgreSQL, and CLI config prerequisites. Use when setting up a new project or diagnosing missing prerequisites.
user-invocable: true
allowed-tools: Bash(*/agent-task *)
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task init ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
