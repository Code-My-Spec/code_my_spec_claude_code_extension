---
name: authenticate
description: Log in to CodeMySpec. Use when authentication is required, the agent reports "not authenticated", or the user asks to log in.
user-invocable: true
allowed-tools: Bash(*/bootstrap-auth-*), Bash(open *)
---

# Authenticate with CodeMySpec

Follow these steps to log the user in:

## Step 1: Check current auth status

Run: `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/bootstrap-auth-status`

If the response shows `"authenticated": true`, tell the user they are already logged in and stop.

## Step 2: Start the OAuth flow

Run: `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/bootstrap-auth-start`

This returns JSON with an `auth_url`. Tell the user:

> I've started the login flow. Please sign in at the URL below (I'll try to open it for you):

Then run: `open "<auth_url>"`

(Replace `<auth_url>` with the actual URL from the response.)

## Step 3: Wait for the user to complete login

Tell the user to complete sign-in in their browser and let you know when done.

## Step 4: Verify authentication

Once the user confirms, run the status check again:
`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/bootstrap-auth-status`

If `"authenticated": true`, confirm success. If not, let the user know it didn't work and offer to retry.
