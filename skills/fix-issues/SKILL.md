---
name: fix-issues
description: Fix accepted QA issues. Uses subagents to fix code and adds resolution sections.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Bash(mix test *), Read, Write, Glob, Grep, Agent
argument-hint: [min_severity]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task fix_issues ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
