---
name: spec-context
description: Generate specifications for all child components of a context
user-invocable: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/cms *), Read, Task
argument-hint: [ContextModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t context_component_specs -m $ARGUMENTS`
