---
name: spec-context
description: Generate specifications for all child components of a context
user-invocable: true
allowed-tools: Bash(./bin/cms *), Read, Task
argument-hint: [ContextModuleName]
---

!`./bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t context_component_specs -m $ARGUMENTS`
