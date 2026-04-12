---
name: triage-issues
description: Triage incoming QA issues. Reviews all issues, proposes dispositions, and moves to accepted/dismissed.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep
argument-hint: [min_severity]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task triage_issues ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
