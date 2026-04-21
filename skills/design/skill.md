---
name: design
description: Architecture design, UI design system, and technology strategy. Use before writing code to plan how to build it.
user-invocable: true
allowed-tools: Bash(*/skill *), Read, Write, Glob, Grep, WebSearch, WebFetch, Task, mcp__plugin_codemyspec_local__*
argument-hint: [architecture|ui|strategy]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill design ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
