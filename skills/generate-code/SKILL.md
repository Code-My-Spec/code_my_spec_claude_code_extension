---
name: generate-code
description: Generate component implementation from spec using agent task session
user-invocable: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/cms *), Read
argument-hint: [ModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t component_code -m $ARGUMENTS`
