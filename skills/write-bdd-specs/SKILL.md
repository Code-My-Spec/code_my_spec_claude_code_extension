---
name: write-bdd-specs
description: Generate BDD Spex tests for the next incomplete user story. Auto-selects the story, generates shared givens, and validates specs compile.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Read, Write, Glob, Grep
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task write_bdd_specs ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
