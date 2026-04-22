---
name: claude-seo
channel: seo
loop_fit: [acquisition, activation]
primary_mcp_status: full-plugin
requires_server_install: false
requires_deploy: false
---

# claude-seo

## What it is
Comprehensive SEO skill-plugin by AgriciDaniel: 20 skills bundling audits, page analysis, technical SEO, E-E-A-T content, schema, sitemaps, local SEO, maps, hreflang, programmatic SEO, competitor pages, GEO, plus Google integrations (GSC, GA4, PageSpeed, CrUX, Indexing). Four credential tiers from API-key-only up to Ads-enabled.

**Installing claude-seo covers GSC and GA4** — you don't need separate recipes for those unless you specifically want MCP-native access for other clients.

## Unlocks
- Activities: "weekly SEO audit," "page CRO audit via seo-page," "schema validation on new posts," "monthly competitor comparison pages," "CrUX field-data pull for CWV review," "backlink profile check," "content gap scan via seo-content," "programmatic SEO template design"
- Sub-skills exposed: `/seo`, `/seo-audit`, `/seo-page`, `/seo-technical`, `/seo-content`, `/seo-schema`, `/seo-images`, `/seo-sitemap`, `/seo-geo`, `/seo-plan`, `/seo-programmatic`, `/seo-competitor-pages`, `/seo-hreflang`, `/seo-local`, `/seo-maps`, `/seo-google`, `/seo-backlinks`, plus MCP-dependent `/seo-firecrawl`, `/seo-dataforseo`, `/seo-image-gen`

## Prerequisites
- Google Cloud Console access (to create a project + service account + API key)
- Domain-level access to Search Console properties to grant the service account
- Admin access to GA4 property to grant the service account

## Install steps
1. **Install the plugin:**
   - `/plugin marketplace add AgriciDaniel/claude-seo` (TODO: verify exact marketplace coordinates; check https://github.com/AgriciDaniel/claude-seo for canonical install)
   - `/plugin install claude-seo`
2. **Set up Google Cloud foundation** (covers GSC + GA4 + PageSpeed + CrUX + Indexing):
   - GCP Console → New Project, note project ID
   - APIs & Services → Library → enable: **Google Search Console API**, **Google Analytics Data API**, **PageSpeed Insights API**, **Chrome UX Report API**, **Web Search Indexing API**, **YouTube Data API v3** (optional, for later YouTube work)
   - IAM & Admin → Service Accounts → Create → name `claude-seo` → Keys → Add Key → Create → JSON → download
   - APIs & Services → Credentials → Create Credentials → API key
3. **Grant the service account access to each property:**
   - **GSC:** Search Console → property → Settings → Users and permissions → Add user → paste service account `client_email` → Full (or Owner for Indexing submissions)
   - **GA4:** analytics.google.com → Admin (gear) → Property Access Management → `+` → paste `client_email` → Viewer
4. **Create the claude-seo config file:** `~/.config/claude-seo/google-api.json`:
   ```json
   {
     "service_account_path": "~/.config/claude-seo/service_account.json",
     "api_key": "AIzaSy...",
     "default_property": "sc-domain:example.com",
     "ga4_property_id": "properties/123456789"
   }
   ```
   Put the downloaded service account JSON at `~/.config/claude-seo/service_account.json` (chmod 600).
5. **Install optional MCP extensions** (per claude-seo's own `extensions/` install scripts):
   - DataForSEO: `./extensions/dataforseo/install.sh` + DataForSEO login/password
   - Firecrawl: `./extensions/firecrawl/install.sh` + `FIRECRAWL_API_KEY`
   - nanobanana (image gen): `./extensions/banana/install.sh` + Gemini API key
6. Verify: `python ~/.claude/skills/seo-google/scripts/google_auth.py --check --json` (or whatever the current check is).

## .env requirements
Most claude-seo credentials live in `~/.config/claude-seo/google-api.json`, NOT `.env`. This is claude-seo's own convention — we don't override it.

`.env` only used for MCP-extension keys:
```
FIRECRAWL_API_KEY=            # for seo-firecrawl extension
DATAFORSEO_LOGIN=             # for seo-dataforseo + seo-backlinks extensions
DATAFORSEO_PASSWORD=
GEMINI_API_KEY=               # for seo-image-gen extension
```

## Validation
Run `/seo google --check` (or equivalent).  The skill's own auth-check script returns a JSON status of which tiers are enabled.

## Conventions to seed
Write `marketing/conventions/seo.md`:

```markdown
# SEO conventions

## Weekly review
- Pull GSC: top 50 landing pages by impressions (28d), top 50 queries (28d)
- Pull GA4: Organic Search sessions by landing page (28d), conversions
- Diff against last week — 3 moves to flag (up or down)

## Content audit cadence
- Monthly: top-10 content audit → candidates for refresh/consolidation
- Quarterly: full content inventory, kill/redirect underperformers

## Technical cadence
- Weekly: `/seo-technical` full crawl
- Monthly: Core Web Vitals via CrUX (27-week history)
- On deploy: `/seo-schema` validation of changed pages

## Submission discipline
- Indexing API: only for approved content types (JobPosting, BroadcastEvent, VideoObject).
- Sitemap changes → submit via `/seo-sitemap` on every structural change.

## Service account hygiene
- Rotate service account key annually.
- Document `client_email` in `marketing/infrastructure.md` so grants are visible.
```

## Gotchas
- **Service account needs to be added as a user in EACH property** (GSC + GA4). Most common gotcha — valid SA with no per-property grants returns 403s that look like auth failures.
- claude-seo stores credentials in a config file, not env. This is different from other recipes. Don't try to force `.env`.
- Indexing API is officially only for JobPosting + BroadcastEvent + VideoObject; Google ignores other URL types.
- GSC URL Inspection hard-capped at 2,000 per site per day.
- GA4 Data API daily token budget (~25K tokens/day free tier).

## Links
- Repo: https://github.com/AgriciDaniel/claude-seo (TODO: verify canonical URL)
- Google Cloud Console: https://console.cloud.google.com
- Search Console: https://search.google.com/search-console
- GA4 Admin: https://analytics.google.com
