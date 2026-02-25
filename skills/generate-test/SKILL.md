---
name: generate-test
description: Generate component tests from spec. Uses TDD patterns, similar component examples, and validates spec alignment and quality thresholds.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep
argument-hint: [ModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task component_test ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
