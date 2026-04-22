# Install one recipe (`/marketing-stack install <name>`)

Guided install for a single recipe. Reads `recipes/<name>/RECIPE.md`, walks through it with the user, ends with a validation call.

**Time in user's mouth: 5-30 minutes depending on recipe.** Some (wix, reddit, ghost) are ~5 min. Postiz is the outlier (30+ due to deploy).

## Phase 1 — Load the recipe

Parse `<name>` from the argument. Normalize: lowercase, hyphens.

Read `recipes/<name>/RECIPE.md`. If the file doesn't exist:
- Suggest close matches from the recipe inventory in `SKILL.md`
- Offer to show the full inventory: "recipe `<name>` not found. Did you mean: `<closest>`? Run `/marketing-stack` (no args) to see the full list."

If the recipe file exists, read it. Recipes are structured markdown with these sections:

- Frontmatter (yaml): `name`, `channel`, `loop_fit`, `requires_server_install`, `requires_deploy`, `primary_mcp_status`
- `## What it is`
- `## Unlocks`
- `## Prerequisites`
- `## Install steps`
- `## .env requirements`
- `## Validation`
- `## Conventions to seed`
- `## Gotchas`
- `## Links`

## Phase 2 — Prerequisites check

Before touching anything, read the Prerequisites section and verify each:

- **Credential dependencies.** E.g., `claude-seo` needs a GCP project. Check if one exists (look for `~/.config/claude-seo/google-api.json`); if not, halt and ask user to complete the prerequisite first.
- **Plugin/MCP dependencies.** E.g., `facebook-publish` routes through Postiz — check if `postiz` is already `ready`. If not: "facebook-publish routes through postiz. Install postiz first with `/marketing-stack install postiz`, or continue with a direct-API setup (not recommended for v1)?"
- **Server-side prerequisites.** E.g., `wordpress` needs mcp-adapter plugin installed on the WP site. Ask: "Have you installed the mcp-adapter plugin on your WordPress site? (yes/no/not yet)." If no/not-yet, show the user the install URL and how-to, wait for confirmation.

Don't proceed past this phase without prerequisites satisfied. That's usually where installs fail — not in the install itself.

## Phase 3 — Walk through install steps

Show each step one at a time with an explicit "ok to proceed?" gate for anything that:

- Touches `~/.claude.json` / `~/.claude/settings.json` (shared state)
- Writes to `.env` (new secrets)
- Runs a deploy command (docker-compose, git clone)
- Changes the user's shell env or installs global npm/pip packages

For each step:

1. Show the command the user will run (or that the skill will run on their behalf).
2. Show the expected outcome.
3. Get explicit "yes" (or "run it"), then execute.
4. Show the result; confirm it matches expectation before moving to the next step.

**If the recipe requires manual user action** (e.g., "open this URL and copy the key"): format the action clearly:

```
### Step 3 — Create the Reddit app

1. Open https://www.reddit.com/prefs/apps
2. Click "create another app"
3. Select "script" type
4. Name: claude-marketing
5. Redirect URI: http://localhost:8080
6. Click "create app"
7. Copy the Client ID (14 chars, under the app name) and Client Secret (27 chars)
8. Come back and tell me "done" when you have them
```

Then wait. When they return, prompt for the values to add to `.env`.

## Phase 4 — Write to `.env`

Secrets never go anywhere else. Procedure:

1. Check for a `.env` file in the project root.
2. If absent, create one and add it to `.gitignore` (create `.gitignore` if absent too).
3. Append the recipe's env vars with the values provided, with a comment block above naming the recipe:

```
# --- marketing-stack: reddit ---
REDDIT_CLIENT_ID=abc123xyz
REDDIT_CLIENT_SECRET=secret_goes_here
REDDIT_USERNAME=your_bot_username
REDDIT_PASSWORD=your_bot_password
# --- end reddit ---
```

4. If an env var already exists in `.env`, ask before overwriting.

**Never** write secrets to `~/.claude.json`, `settings.json`, MCP config JSON, or any git-tracked file. MCP configs reference env vars via `${VAR_NAME}` interpolation or the client's documented env-passthrough mechanism.

## Phase 5 — Register the MCP (if applicable)

For MCP-backed recipes: add the MCP to the user's Claude Code config. Preferred approach:

```bash
claude mcp add --transport stdio <name> -s user -- npx -y <package>
```

`-s user` scopes the MCP to the user (visible across all projects). If the user prefers project-scoped, use `-s project` — ask once, remember for this session.

Env vars in MCP config should interpolate from `.env`:

```json
{
  "mcpServers": {
    "ghost": {
      "command": "npx",
      "args": ["-y", "@fanyangmeng/ghost-mcp"],
      "env": {
        "GHOST_API_URL": "${GHOST_API_URL}",
        "GHOST_ADMIN_API_KEY": "${GHOST_ADMIN_API_KEY}",
        "GHOST_API_VERSION": "${GHOST_API_VERSION}"
      }
    }
  }
}
```

If the user's Claude Code version doesn't support `.env` interpolation in MCP configs, fall back to using `env` blocks with inline values — but **warn the user explicitly** that this is writing secrets into `~/.claude.json`, against the `.env`-only discipline, and recommend upgrading Claude Code.

## Phase 6 — Seed conventions

Read the recipe's `## Conventions to seed` section. For each file:

1. Check if it already exists at `marketing/conventions/<file>.md`.
2. If yes, show the diff between what's there and what the recipe suggests; ask before overwriting or merging.
3. If no, write it.
4. These files are marketing-specific operational patterns (e.g., Reddit UTM format, Stripe metadata conventions for attribution, Ghost tagging conventions). Short, opinionated, editable by the user.

If the recipe has no conventions section, skip this phase.

## Phase 7 — Validate

Run the `## Validation` call from the recipe. This is the moment of truth.

- If it works: mark the recipe `ready` in internal state (to be written to `infrastructure.md` later).
- If it fails: show the exact error, match it against the `## Gotchas` section if any match, and either (a) fix it with the user's input, or (b) mark the recipe `setup-pending` and point at `/marketing-stack fix <name>` for a future session.

Don't pretend success. A recipe without a passing validation is not ready.

## Phase 8 — Update `infrastructure.md`

If `marketing/infrastructure.md` exists, update just the affected row. Keep changes minimal.

If it doesn't exist, don't auto-generate it — the user runs `/marketing-stack blueprint` when they want it. Instead, tell them:

> "Recipe installed and verified. Run `/marketing-stack blueprint` to regenerate `marketing/infrastructure.md` with the new entry."

## Phase 9 — Close

Short summary:

> "`<recipe>` installed. `<tool count or capability summary>`. Next: either install a dependent recipe (`<suggestion>`), or if you're done, regenerate the blueprint. If anything breaks later, `/marketing-stack fix <recipe>`."

Don't dump the full recipe content. Point at files.

## Anti-patterns

- **Installing without prerequisites.** Every failure-to-install I've seen in real use is a missed prerequisite. Check hard.
- **Writing secrets outside `.env`.** Treat this as a hard rule. Violations are bugs.
- **Silent success.** Every install ends with the validation call actually passing.
- **Optimistic auto-registration of MCPs without consent.** `claude mcp add` modifies user state. Always confirm.
- **Glossing over server-side installs.** WordPress mcp-adapter install, Postiz deploy — these require explicit user action on their side. Document, verify, never skip.
- **Skipping convention seeding.** The conventions files are small but load-bearing — they're what makes the daily-plan skill able to run the activity correctly.
