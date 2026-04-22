---
name: ghost
channel: content
loop_fit: [acquisition, activation, monetization]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
---

# Ghost

## What it is
Ghost CMS + native newsletter + paid memberships via `@fanyangmeng/ghost-mcp` (MFYDev). TypeScript MCP, MIT, active.

## Unlocks
- Activities: "draft weekly newsletter," "publish post + trigger member send," "tier performance audit," "create limited-time offer," "member engagement review"

## Prerequisites
- A Ghost site (self-hosted or Ghost Pro)
- Admin access to Ghost to create an integration

## Install steps
1. **Create Ghost integration (admin action on the Ghost site):**
   - Ghost Admin → Settings → Integrations → Add custom integration
   - Name: `claude-marketing-stack`
   - Copy the **Admin API Key** (format: `id:secret` — 26-char id + 64-char hex secret, colon-separated)
   - Note the **API URL** (e.g., `https://yourblog.com`, no trailing slash)
2. **Register the MCP locally:**
   ```bash
   claude mcp add --transport stdio ghost -s user -- npx -y @fanyangmeng/ghost-mcp
   ```
3. **Wire env vars** — see `.env requirements` below. Add to project `.env`.
4. **Reference env from MCP config.** Claude will auto-pass env through if `claude mcp add -e` was used, otherwise edit `~/.claude.json`:
   ```json
   "ghost": {
     "command": "npx",
     "args": ["-y", "@fanyangmeng/ghost-mcp"],
     "env": {
       "GHOST_API_URL": "${GHOST_API_URL}",
       "GHOST_ADMIN_API_KEY": "${GHOST_ADMIN_API_KEY}",
       "GHOST_API_VERSION": "${GHOST_API_VERSION}"
     }
   }
   ```
5. Restart Claude to pick up the MCP.

## .env requirements
```
GHOST_API_URL=           # https://yourblog.com (no trailing slash)
GHOST_ADMIN_API_KEY=     # id:secret from Ghost integration page
GHOST_API_VERSION=v5.0   # pin; bump when your Ghost major version moves
```

## Validation
Ask Claude: "Using the Ghost MCP, list the last 5 posts." Expect JSON with `id`, `title`, `slug`, `published_at`.

## Conventions to seed
Write `marketing/conventions/content.md` (create or merge):

```markdown
# Content conventions (Ghost)

## Post-vs-newsletter
- Default: every post emails members (Ghost's built-in newsletter send).
- Blog-only: set `email_recipient_filter: none` in the draft before publish.
- Newsletter-only (no public post): keep status as email-only.

## Tagging
- Use `#newsletter` for newsletter-only sends to distinguish in archive.
- Max 3 tags per post.

## Tiers / members
- Free tier: newsletter posts.
- Paid tier: premium posts locked behind `visibility: paid`.

## Migration
- If moving from WordPress, use Ghost's importer. Don't dual-publish.
```

## Gotchas
- Admin API Key is `id:secret` format — copy the whole string including the colon.
- No documented rate limits; Ghost's Admin API is generous (~100 req/min assumed).
- `email_recipient_filter` controls who gets emailed on publish.
- Admin API doesn't support member password reset — use the Ghost UI.
- Ghost Pro customers: API URL is `https://<subdomain>.ghost.io`; self-hosted: your domain.

## Links
- Source: https://github.com/MFYDev/ghost-mcp
- npm: https://www.npmjs.com/package/@fanyangmeng/ghost-mcp
- Ghost Admin API: https://ghost.org/docs/admin-api/
