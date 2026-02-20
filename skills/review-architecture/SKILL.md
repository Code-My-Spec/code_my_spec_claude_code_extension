---
name: review-architecture
description: Review architecture against best practices. Reports on surface-to-domain separation, dependency health, circular dependencies, orphaned components, and story coverage.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, mcp__plugin_codemyspec_architecture-server__*
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task architecture_review ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
