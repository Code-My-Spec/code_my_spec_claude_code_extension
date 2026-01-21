---
name: generate-test
description: Generate component tests from spec using agent task session
user-invocable: true
allowed-tools: Bash(./bin/cms *), Read
argument-hint: [ModuleName]
---

!`./bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t component_test -m $ARGUMENTS`
