---
name: technical-strategy
description: Identify technology decisions, research options, and produce decision records with supporting knowledge.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, WebSearch, WebFetch, Task
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task technical_strategy ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
