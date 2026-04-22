---
name: gsc
channel: seo
loop_fit: [acquisition]
primary_mcp_status: via-claude-seo
requires_server_install: false
requires_deploy: false
---

# Google Search Console

## What it is
Search Console API (Search Analytics, URL Inspection, Sitemaps). The authoritative source for how Google sees your site in organic search.

**If `claude-seo` is installed, GSC is already covered via its `seo-google` sub-skill** — this recipe is redundant in that case.

This recipe only matters if:
- You don't want the full claude-seo plugin, OR
- You need MCP-native GSC tool calls in a client other than Claude Code (e.g., Claude Desktop without claude-seo's Python wrappers).

## Unlocks
- Activities: "weekly top-50 landing-page impressions pull," "keyword position tracking," "sitemap submission check," "URL Inspection batch (up to 2,000/site/day)"

## Prerequisites
- Google Cloud project + service account (shared with `ga4`, `youtube`, `claude-seo`)
- Service account granted access to each GSC property

## Install steps

### Primary path: via claude-seo

If you installed `claude-seo`, GSC is working. No additional install. Use `/seo-google` sub-skill.

### Alternative: standalone thin MCP wrapper (⚠️ custom, no canonical option)

No canonical community GSC MCP exists as of April 2026. If you genuinely need standalone access:

1. Write a minimal MCP wrapper over `google-api-python-client`'s `searchconsole` v1 resource — ~100 lines of Python. Not in scope for this recipe; it's a v2 target we'd own ourselves if demand justifies.
2. Until then, use DataForSEO (`seo-dataforseo`) for public SERP data as a partial substitute, with the caveat: that's external data (public rankings), not property-owner data.

## API setup (if building a custom wrapper)

1. GCP project: reuse the one from `claude-seo` or `ga4`.
2. Enable APIs: **Google Search Console API** + **Web Search Indexing API** (if you want submission support).
3. Service account: IAM & Admin → Service Accounts → `claude-gsc` → Keys → Add Key → JSON → store at `~/.config/claude-seo/service_account.json` (chmod 600).
4. **Grant service account access to each GSC property:**
   - Search Console → property → Settings → Users and permissions → Add user → paste service account `client_email` → **Full** (SA+URL+Sitemaps) or **Owner** (required for Indexing API submissions).
5. Property URL format: `sc-domain:example.com` (domain properties) or `https://example.com/` (URL-prefix).

## Required OAuth scopes
- `https://www.googleapis.com/auth/webmasters.readonly` — Search Analytics + URL Inspection + sitemap listing
- `https://www.googleapis.com/auth/webmasters` — sitemap submit/delete
- `https://www.googleapis.com/auth/indexing` — Indexing API publish/delete

## .env requirements
```
# If using claude-seo (recommended), GSC creds live in ~/.config/claude-seo/google-api.json.
# No .env vars needed.

# If using a custom MCP wrapper:
GOOGLE_APPLICATION_CREDENTIALS=   # absolute path to service account JSON
GSC_DEFAULT_PROPERTY=             # sc-domain:example.com
```

## Validation
Via claude-seo: `/seo google check` (or equivalent).
Via custom wrapper: call Search Analytics query endpoint for last 7 days — expect non-empty rows.

## Conventions to seed
Covered by `marketing/conventions/seo.md` (written by `claude-seo` recipe).

## Gotchas
- **Per-property grants required.** Valid SA with no per-property grants returns 403s that look like auth failures.
- URL Inspection hard-capped at **2,000 per site per day**.
- Indexing API: 380 RPM, 200 publish/day, officially JobPosting + BroadcastEvent/VideoObject only — Google ignores other URL types.
- Search Analytics: 1,200 QPM/site, 30M QPD (generous).

## Links
- Via claude-seo: `/seo-google` skill.
- GSC API: https://developers.google.com/webmaster-tools/v1/api_reference_index
- google-api-python-client: https://github.com/googleapis/google-api-python-client
