---
name: implement-context
description: Generate tests and implementations for a context and its child components
user-invocable: true
allowed-tools: Bash(./bin/cms *), Read, Task
argument-hint: [ContextModuleName]
---

!`./bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t implement_context -m $ARGUMENTS`
