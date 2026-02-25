---
name: sync
description: Sync project components and regenerate architecture views. Use before architecture design, after git pulls, or when views seem stale.
user-invocable: true
allowed-tools: Bash(*/agent-task *)
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task sync ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
