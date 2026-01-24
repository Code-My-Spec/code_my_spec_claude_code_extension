---
name: generate-spec
description: Generate a component or context specification using agent task session
user-invocable: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/cms *), Read
argument-hint: [ModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t spec -m $ARGUMENTS`
