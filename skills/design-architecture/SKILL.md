---
name: design-architecture
description: Start a guided architecture design session. Maps unsatisfied user stories to surface components, identifies bounded contexts, and validates proposals before execution.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, mcp__plugin_codemyspec_architecture-server__*
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task architecture_design ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
