---
name: qa-story
description: QA a single user story. Plans testing approach, executes tests with web tool, and writes results with evidence.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Bash(web *), Bash(curl *), Bash(lsof *), Bash(mix phx.*), Bash(mix run *), Bash(*/scripts/*), Read, Write, Glob, Grep
argument-hint: [story_id]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task qa_story ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
