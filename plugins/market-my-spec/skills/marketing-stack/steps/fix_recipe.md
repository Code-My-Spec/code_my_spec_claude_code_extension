# Fix a broken recipe (`/marketing-stack fix <name>`)

Diagnostic + re-auth flow for a recipe whose install was working (or was expected to work) but isn't right now. Used when the user hits a "creds expired" / "MCP not responding" / "tool returned auth error" problem.

**This skill does NOT do continuous health monitoring.** It only responds to user-initiated "something's wrong." (Continuous monitoring is a separate future skill.)

## Phase 1 — Parse & load

Parse `<name>`. Read `recipes/<name>/RECIPE.md` for the validation call and gotchas section.

## Phase 2 — Diagnose

Step through checks in this order, stopping at the first failing one:

### 2a. Does `.env` exist and have the recipe's vars?

- Read `.env` at the project root.
- Check for each env var listed in the recipe's `## .env requirements` section.
- Missing var → ask the user to provide it. Don't assume it's elsewhere.

### 2b. Is the MCP registered?

- Check `~/.claude.json`, `~/.claude/settings.json`, project `.mcp.json`.
- If the MCP should be registered per the recipe but isn't: re-register with `claude mcp add ...`.

### 2c. Can the MCP start?

- For stdio MCPs: try `npx -y <package> --version` or similar non-invasive check.
- If the package fails to resolve, reinstall.

### 2d. Do the credentials authenticate?

- Run the recipe's validation call.
- Parse the error:
  - **401/403 with expired token** → re-auth flow (OAuth browser or new app password)
  - **403 with insufficient scope** → check the recipe's required scopes against what's configured; fix
  - **429 rate-limited** → ask user to wait and retry; not a config problem
  - **Network error** → check URL in `.env` is reachable (the WP site, Postiz URL, etc.)
  - **Unknown error** → surface it, show the recipe's gotchas, ask user for next step

### 2e. Re-auth flow (the common case)

Many recipes have tokens that expire:

- **Meta Page Access Token** — 60 days. Re-auth via Graph API Explorer (see facebook-ads recipe).
- **LinkedIn access token** — 60 days; `refresh_token` 1-year capped. Re-do OAuth.
- **Google service account** — doesn't expire but can be revoked. Regenerate JSON key.
- **WordPress OAuth** — handled by mcp-wordpress-remote; clear the client's cache, re-auth.
- **Stripe restricted key** — doesn't expire but can be rotated. Regenerate.
- **Reddit password auth** — doesn't expire unless account password changed.

For each, the fix is "re-run the credential-creation step from the recipe and update `.env`." Walk through it.

## Phase 3 — Validate again

After fix, re-run the recipe's validation call. Don't declare success without it passing.

## Phase 4 — Update state

Update `marketing/infrastructure.md` row for this recipe:
- Status → `ready`
- Last verified → today's date
- Notes → append "Fixed <issue> on <date>"

## Phase 5 — If fix failed

If after a reasonable effort the recipe still isn't working:
- Mark it `blocked` in infrastructure.md
- Surface a diagnostic summary: what was checked, what failed
- Recommend:
  - File a bug against the MCP's upstream repo (link from the recipe's `## Links`)
  - Fall back to the ⚠️ direct-API path if the recipe has one documented
  - Check if the underlying service is having an outage (look at their status page URL from the recipe if provided)

Don't leave the user guessing. Even a failed fix produces a structured report.

## Anti-patterns

- **Declaring fix success without re-validation.** Same rule as install.
- **Guessing at the error cause.** Read the actual error message, match to gotchas, then decide.
- **Clearing all `.env` vars to "start fresh."** Never. Fix specifically.
- **Skipping credential-rotation check.** Tokens expire more often than users remember. When in doubt, assume expiry and re-auth.
