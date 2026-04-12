---
name: research-topic
description: Research a specific technology topic. Produces a knowledge entry and decision record.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep, WebSearch, WebFetch, Task
argument-hint: [topic]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task research_topic ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
