---
name: develop-liveview
description: Orchestrate the full lifecycle of a LiveView from specification through implementation
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, Task
argument-hint: [LiveViewModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task develop_live_view ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
