---
name: generate-spec
description: Generate a component or context specification using agent task session
user-invocable: true
allowed-tools: Bash(./bin/cms *), Read
argument-hint: [ModuleName]
---

!`./bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t spec -m $ARGUMENTS`
