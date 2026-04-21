---
name: implement
description: Autonomous implementation loop — start or stop requirements-driven development. The agent walks the requirement graph automatically.
user-invocable: true
allowed-tools: Bash(*/skill *), Read, Write, Glob, Grep, Task
argument-hint: [start|stop]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill implement ${CLAUDE_SESSION_ID} $ARGUMENTS`

If the response contains a `prompt` field, extract and follow it.

If the response is `{"stopped": true}`: Agentic mode has been disabled. The agent will no longer automatically continue to the next task. To resume, use `/codemyspec:implement` or `/codemyspec:implement start`.
