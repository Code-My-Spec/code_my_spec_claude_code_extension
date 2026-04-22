---
name: postiz
channel: social
loop_fit: [acquisition, retention]
primary_mcp_status: bundled
requires_server_install: false
requires_deploy: true
---

# Postiz

## What it is
Self-hosted open-source social media scheduler that cross-posts to ~15 networks from a single queue. Includes a bundled MCP server in the main repo (`gitroomhq/postiz-app` under `libraries/mcp`). Published under AGPL-3.0 + commercial license.

**The single biggest auth-complexity lever for social.** One Postiz deploy = one OAuth dance per channel, inside Postiz. FB + IG + LinkedIn + Twitter + YouTube + Reddit + TikTok all collapsed into one integration.

## Unlocks
- Channels: X, LinkedIn (personal + Company Page), Facebook Page, Instagram, YouTube, Threads, Bluesky, TikTok, Pinterest, Reddit, Mastodon, Dribbble
- Activities: "daily social post batch," "weekly content scheduling sweep," "cross-channel announcement," "evergreen re-queue"

## Prerequisites
- A host for Postiz. v1 of this recipe supports two paths:
  - **Local docker-compose** (for dev / try-it-out)
  - **Bring-your-own hosted URL** (for production — user deploys elsewhere)
- Postgres + Redis (included in Postiz's docker-compose)
- A domain with TLS if deploying for production (social OAuth redirects need HTTPS)

**V2 roadmap note:** Hetzner deployment helper is planned but not in v1. v3 might be a hosted offering. For now, deploy is user-driven.

## Install steps

### Path A: Local docker-compose (dev, try-it-out)

1. Clone the repo:
   ```bash
   git clone https://github.com/gitroomhq/postiz-app.git
   cd postiz-app
   ```
2. Configure env (Postiz's own `.env` file, not the marketing project's):
   ```
   MAIN_URL=http://localhost:4200
   FRONTEND_URL=http://localhost:4200
   NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
   JWT_SECRET=<generate with: openssl rand -hex 32>
   ```
3. `docker compose up -d` — brings up Postiz + Postgres + Redis.
4. Open http://localhost:4200, create the first admin account.

### Path B: Bring-your-own hosted URL (production)

1. User has already deployed Postiz (Railway one-click, self-hosted VPS, etc.) and has a working URL.
2. User has created an admin account in the Postiz UI.
3. Skip to "Connect social channels" below.

### Both paths — connect channels + wire MCP

5. **Inside the Postiz web UI**, connect each social channel via OAuth. This is where the Meta/LinkedIn/X app-review pain lives — Postiz uses its own Meta app + LinkedIn app + X app, so the user rides on Postiz's pre-approved status.
6. **Generate API key:** Postiz Settings → API → Generate personal API key (format: `postiz_xxxxxxxxxxxx`).
7. **Register the MCP:**
   ```bash
   claude mcp add --transport stdio postiz -s user -- npx -y @gitroom/postiz-mcp
   ```
   (Package name as of 2026-04; verify in postiz-app/libraries/mcp/README.md.)
8. Add env vars to `.env`.

## .env requirements
```
POSTIZ_URL=              # https://your-postiz.example.com OR http://localhost:4200
POSTIZ_API_KEY=          # postiz_xxxxxxxxxxxx from Settings → API
```

## Validation
Ask Claude: "Using the Postiz MCP, list my connected social channels." Expect JSON with ≥1 channel ID.

## Conventions to seed
Write `marketing/conventions/social.md`:

```markdown
# Social conventions (via Postiz)

## Posting flow
- Draft in Postiz UI or MCP; schedule, never immediate-publish.
- Per-channel text variants — don't cross-post identical text.
- Include images/video natively — link cards degrade in most feeds.

## Cadence
- X/Twitter: 1-3 posts/day max; engage 10x for every 1 post.
- LinkedIn: 1 post/day max; tuesday-thursday peak.
- Instagram: 3-5/week; stories daily if campaign active.
- Facebook: 1 post/day, optimize for share/comment.
- Reddit: use Postiz for Show-type submissions; not for comments (use real account).

## Token refresh discipline
- Check queue weekly — if anything shows "auth failed," re-OAuth in Postiz UI.
- Meta tokens especially — 60-day lifetime.

## Analytics pull
- Weekly: per-post reach/engagement from Postiz analytics.
- Monthly: best-performing posts across channels → inform next cycle content.

## Account vs brand
- Solo founder: personal brand on X + LinkedIn; brand on IG + FB.
- Don't merge streams — audience mismatch.
```

## Gotchas
- **Deployment is user-driven in v1.** Hetzner helper is v2.
- Downstream platform rate limits pass through (X 300/3h, LinkedIn 150/day, etc.).
- First-time OAuth still needs Meta/X/LinkedIn developer apps in the right state — Postiz holds them, but check per-channel status.
- Self-hosted = user handles token refresh failures; check the queue weekly.
- MCP tool surface lags Postiz web UI by a release or two.
- AGPL-3.0 license: if commercial use + modifications, consider Postiz's commercial license.

## Links
- Source: https://github.com/gitroomhq/postiz-app
- Docs: https://docs.postiz.com
- MCP subpath: https://github.com/gitroomhq/postiz-app/tree/main/libraries/mcp
- Railway template: https://railway.app/template/postiz (community-maintained)
