---
name: qa-setup
description: Set up QA infrastructure. Analyzes the app and writes the QA plan with tools, auth scripts, and seed strategy.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Bash(web *), Bash(curl *), Bash(lsof *), Bash(mix phx.*), Bash(mix run *), Read, Write, Glob, Grep
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task qa_setup ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
