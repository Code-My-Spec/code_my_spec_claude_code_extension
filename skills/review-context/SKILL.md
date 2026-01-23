---
name: review-context
description: Review a context design and its child components for architecture issues
user-invocable: true
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/bin/cms *), Read, Edit
argument-hint: [ContextModuleName]
---

!`${CLAUDE_PLUGIN_ROOT}/bin/cms start-agent-task -e ${CLAUDE_SESSION_ID} -t context_design_review -m $ARGUMENTS`
