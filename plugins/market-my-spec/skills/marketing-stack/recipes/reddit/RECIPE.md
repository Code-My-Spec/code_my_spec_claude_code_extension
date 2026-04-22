---
name: reddit
channel: reddit
loop_fit: [acquisition]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
---

# Reddit

## What it is
Reddit browsing, search, and user/thread analysis via `reddit-mcp-buddy` (karanb192). 621 stars, v1.1.12 (Feb 2026). Three-tier auth: anonymous (10 rpm), app-only (60 rpm), authenticated (100 rpm).

**Read-only MCP.** Posting/commenting is a separate concern — best through Postiz (which supports Reddit) or manual. Matches the "John dictates, AI polishes" discipline.

## Unlocks
- Activities: "daily scan for empathy threads in target subs," "competitor/persona user research," "weekly subreddit trend check," "find threads where product is genuine answer," "draft comment with context"

## Prerequisites
- **Tier 1 (anonymous):** none
- **Tier 2+ (recommended for real use):** a Reddit account — ideally a dedicated "tools" account, not your personal one

## Install steps
1. **(Optional but strongly recommended)** Create Reddit app at https://www.reddit.com/prefs/apps:
   - Click "create another app"
   - Select **script** type for 100 rpm authenticated
   - Name: `claude-marketing`
   - Redirect URI: `http://localhost:8080` (not actually used for script type, but required field)
   - Click "create app"
   - Copy the 14-char Client ID (shown under the app name) and 27-char Client Secret
2. **Register the MCP:**
   ```bash
   claude mcp add --transport stdio reddit -s user -- npx -y reddit-mcp-buddy
   ```
3. Add env vars to `.env` per the tier you chose.
4. Reference `.env` from `~/.claude.json` env block for the reddit MCP entry.

## .env requirements
```
# Tier 1 (anonymous, 10 rpm): no vars

# Tier 2 (app-only, 60 rpm):
REDDIT_CLIENT_ID=            # 14-char from Reddit app page, under app name
REDDIT_CLIENT_SECRET=        # 27-char from Reddit app page, labeled "secret"

# Tier 3 (authenticated, 100 rpm) — adds:
REDDIT_USERNAME=             # account that created the script app
REDDIT_PASSWORD=             # account password (use dedicated bot account)
```

## Validation
Ask Claude: "Using reddit-mcp-buddy, browse r/elixir hot, 3 posts." Expect JSON with title, author, url, score.

## Conventions to seed
Write `marketing/conventions/reddit.md`:

```markdown
# Reddit conventions

## UTM format
- Campaign = topic slug, not page slug: `?utm_source=reddit&utm_medium=comment&utm_campaign=agentic-coding-process`
- Medium = `comment` or `post`

## Pacing rule
- Max 2-3 substantive comments per session; spread across the day.
- Never burst 6+ in one window (rate-limit + community-perception).

## Link discipline
- Never link to homepage. Always a specific content page earning the click.
- URL prefixes: `/pages/:slug`, `/blog/:slug`, `/documentation/:slug`. Bare slugs 404.

## Voice
- Answer first, link second. Substantive value up front.
- Em dashes → plain hyphens (Reddit spam filters).
- Two-comment strategy: short no-link comment for upvotes + reply with link for clicks.

## Touchpoint log
- Every engagement → one line in `marketing/touchpoints.md` with date, subreddit, thread URL, comment URL, link used.

## Account hygiene
- Primary voice: your real account.
- Tools account (for authenticated-mode MCP): dedicated, not personal.
- Don't post from a freshly-created account.
```

## Gotchas
- Rate limits are honest — pacing matters for daily scan activity.
- Cache TTLs: 15min anonymous, 5min authenticated.
- `search_reddit` with broad queries burns rate-limit; always add a subreddit filter.
- Script app Reddit account should not be your personal one.
- MCP provides NO posting capability.

## Links
- Source: https://github.com/karanb192/reddit-mcp-buddy
- Reddit app setup: https://www.reddit.com/prefs/apps
