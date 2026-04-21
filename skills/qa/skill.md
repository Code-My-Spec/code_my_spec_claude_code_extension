---
name: qa
description: QA testing and issue management — full app QA, per-story QA, integration planning, issue triage, and fixes.
user-invocable: true
allowed-tools: Bash(*/skill *), Bash(web *), Bash(curl *), Bash(lsof *), Bash(mix phx.*), Bash(mix run *), Bash(mix test *), Read, Write, Glob, Grep, Task, Agent
argument-hint: [story <id>|integrations|triage [severity]|fix [severity]]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill qa ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
