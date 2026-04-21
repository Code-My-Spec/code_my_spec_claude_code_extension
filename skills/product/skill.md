---
name: product
description: Product management — guided story interview and review sessions. Use when defining what to build, refining requirements, or reviewing story quality.
user-invocable: true
allowed-tools: Bash(*/skill *), mcp__plugin_codemyspec_local__*
argument-hint: [interview|review]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill product ${CLAUDE_SESSION_ID} $ARGUMENTS`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
