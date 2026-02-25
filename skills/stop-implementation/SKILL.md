---
name: stop-implementation
description: Stop the implementation lifecycle by disabling agentic mode. Use /manage-implementation to resume.
user-invocable: true
allowed-tools: Bash(*/cms *)
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/bin/cms set-agentic-mode --disable`

Agentic mode has been disabled. The agent will no longer automatically continue to the next task after completing work.

To resume the implementation lifecycle, use `/manage-implementation`.
