---
name: generate-code
description: Generate component implementation from its spec and test file. References similar components for patterns and applies coding rules.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep
argument-hint: [ModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task component_code ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
