---
name: wordpress
channel: content
loop_fit: [acquisition, activation, monetization]
primary_mcp_status: official-server-plus-client
requires_server_install: true
requires_deploy: false
---

# WordPress

## What it is
WordPress CMS + WooCommerce via a two-piece MCP architecture:
- **Server-side (on the WP site):** `WordPress/mcp-adapter` — official WordPress.org PHP plugin, 931 stars, v0.5.0 (Apr 2026)
- **Client-side (on the user's machine):** `@automattic/mcp-wordpress-remote` — Automattic Node.js MCP, active

OAuth 2.1 default. Works for both self-hosted WordPress and WordPress.com (Business plan and up).

## Unlocks
- Activities: "draft weekly post," "audit top-10 posts by traffic," "update CTAs on pillar pages," "WooCommerce: weekly order review," "content cluster cross-linking"

## Prerequisites
- WordPress 6.6+ (for full Abilities API)
- Admin access to the WordPress site (for server-side plugin install)
- HTTPS — OAuth won't work on plain HTTP

## Install steps
1. **On the WP site (user-driven, document + verify):**
   - WP Admin → Plugins → Add New → search or upload `mcp-adapter` from https://github.com/WordPress/mcp-adapter
   - Or via WP-CLI: `wp plugin install https://github.com/WordPress/mcp-adapter/releases/latest/download/mcp-adapter.zip --activate`
   - Verify the plugin exposes `/wp-json/wp/v2/mcp/` — curl: `curl https://<site>/wp-json/wp/v2/mcp/` should return JSON (might be 401 without auth, that's fine).
   - Ask the user: "mcp-adapter plugin installed and activated on the site? (yes/no)" — wait for `yes` before continuing.

2. **On the user's machine:**
   ```bash
   claude mcp add --transport stdio wordpress -s user -- npx -y @automattic/mcp-wordpress-remote
   ```
3. Add `WP_API_URL` to `.env` pointing at the site.
4. First call triggers the OAuth 2.1 browser flow. User authorizes. Token cached locally by mcp-wordpress-remote.

## .env requirements
```
WP_API_URL=             # https://yoursite.com (no trailing slash)
# Fallbacks (only if NOT using OAuth — self-hosted only):
WP_API_USERNAME=        # WP admin username (Application Passwords path)
WP_API_PASSWORD=        # 24-char Application Password from Users → Profile → Application Passwords
```

## Validation
Ask Claude: "Using the WordPress MCP, list my 5 most recent posts." Expect post IDs + titles.

## Conventions to seed
Write `marketing/conventions/content.md` (create or merge):

```markdown
# Content conventions (WordPress)

## Drafting
- New post → draft first, never direct publish from MCP.
- SEO fields (Yoast/RankMath meta title + description) set before publish.
- Featured image required.

## Categories / tags
- Use existing; max 1 category + 3 tags per post.

## CTA discipline
- Every post gets a relevant CTA block — audit monthly.
- Internal links: to money pages, not to more content-for-content.

## WooCommerce (if applicable)
- Never bulk-edit products via MCP without a dry-run.
- Weekly order review → feeds revenue conversations, not marketing work.
```

## Gotchas
- Server-side install requires WP admin access. Managed hosts (WP Engine, Kinsta) may restrict arbitrary plugin install — confirm first.
- WordPress.com: Personal/Premium plans don't support arbitrary plugins. Business plan and up OR use OAuth-only path against WP.com hosted endpoints.
- `mcp-adapter` requires WP 6.6+ for full Abilities API.
- Security plugins (Wordfence, iThemes) may block `/wp-json/wp/v2/mcp/` — whitelist needed.
- WooCommerce tools only appear if WooCommerce is active on the site.

## Links
- Adapter (server): https://github.com/WordPress/mcp-adapter
- Remote (client MCP): https://github.com/Automattic/mcp-wordpress-remote
- Migrating from old Automattic/wordpress-mcp (archived): docs in mcp-adapter repo
