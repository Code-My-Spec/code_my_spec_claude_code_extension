---
name: manage-implementation
description: Orchestrate the full implementation lifecycle. Enables agentic mode and loops write-bdd-specs then implement-context until all stories pass.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, Task
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task manage_implementation ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
