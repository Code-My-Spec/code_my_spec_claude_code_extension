---
name: develop
description: Full-lifecycle development — context orchestration, LiveView orchestration, and interactive refactoring. Spawns subagents for multi-step workflows.
user-invocable: true
allowed-tools: Bash(*/skill *), Read, Write, Edit, Glob, Grep, Task
argument-hint: [context|liveview|refactor] [ModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill develop ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
