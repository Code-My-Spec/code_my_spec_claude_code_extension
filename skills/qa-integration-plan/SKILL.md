---
name: qa-integration-plan
description: Plan third-party integrations. Reads technical decisions, drafts integration specs, generates verify scripts, and coordinates credential setup with the user.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Bash(web *), Bash(curl *), Bash(lsof *), Bash(mix phx.*), Bash(mix run *), Read, Write, Glob, Grep
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task qa_integration_plan ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
