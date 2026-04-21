---
name: init
description: Project setup, authentication, and sync. Use when starting a new project, logging in, or refreshing stale state.
user-invocable: true
allowed-tools: Bash(*/skill *), Bash(*/bootstrap-auth-*), Bash(open *)
argument-hint: [auth|sync]
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/skill init ${CLAUDE_SESSION_ID} $ARGUMENTS`

If the response contains a `prompt` field, extract and follow it.

If the response is `{"auth": true}`, follow the auth flow:

1. Run: `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/bootstrap-auth-status`
   - If `"authenticated": true`, tell the user and stop.

2. Run: `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/bootstrap-auth-start`
   - Returns JSON with `auth_url`. Tell the user, then run: `open "<auth_url>"`

3. Wait for the user to confirm they completed sign-in.

4. Run status check again. Confirm success or offer retry.
