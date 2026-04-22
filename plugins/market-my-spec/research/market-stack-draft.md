# `/market-stack` — Research draft

*Raw research output from 4 parallel agent runs + direct WebFetch, 2026-04-21. Not yet synthesized into final recipes.*

## Context

`/market-stack` is the planned third skill in `market-my-spec` (after `/marketing-strategy` and `/daily-plan`). Goal: help solo founders stand up the marketing infrastructure their strategy calls for. Recipe-based, opinionated, `.env`-only secrets, never writes to MCP config files.

**V1 scope (14 recipes being researched):** Postiz, Facebook, Instagram, LinkedIn, Twitter/X, YouTube, claude-seo, Google Search Console, GA4, WordPress, HubSpot, Stripe, BillionMail, Reddit.

**V1 additions from research:** Ghost (content + newsletter fused), Resend (SaaS email, replaces BillionMail for v1). **V2 deferrals:** BillionMail (no API yet).

---

## Cluster 1 — Social publishing (6 recipes)

### Recipe: Postiz

**What it is.** Self-hosted open-source social media scheduler that cross-posts to ~15 networks from a single queue, with an MCP server bundled in the main repo.

**Unlocks.** Cross-posts to X, LinkedIn (personal + company), Facebook Page, Instagram, YouTube, Threads, Bluesky, TikTok, Pinterest, Reddit, Mastodon, Dribbble. Activities: "daily social post batch," "weekly content scheduling sweep," "cross-channel announcement," "evergreen re-queue."

**Capabilities.**
- Write/publish: schedule, immediate publish, media upload, per-channel text variants, drafts, calendar view
- Read/intelligence: per-post analytics for supported channels, scheduled-queue introspection, team activity

**Opinionated pick.** Postiz's own MCP (lives in `gitroomhq/postiz-app` under `libraries/mcp`). Host Postiz, connect each social channel via its web UI, point Claude at the MCP with a Postiz API key. One integration, dodges six OAuth dances.

**Alternatives rejected.** Buffer (SaaS, no MCP, paid). Hootsuite (enterprise). Mixpost (self-hosted PHP, no MCP). Typefully (X-only).

**Install.**
1. Deploy Postiz: Railway one-click or docker-compose on a $5 VPS. Postgres + Redis required (included in compose).
2. Set `MAIN_URL`, `FRONTEND_URL`, `NEXT_PUBLIC_BACKEND_URL`, `JWT_SECRET` in Postiz env before first boot.
3. Open Postiz web UI, connect each social channel via its OAuth inside Postiz (where the Meta/LinkedIn/X pain happens).
4. Settings → API → generate personal API key.
5. Add MCP server to `.mcp.json` with hosted URL; `POSTIZ_API_KEY` and `POSTIZ_URL` in `.env`.

**.env:**
```
POSTIZ_URL=                 # https://your-postiz.example.com
POSTIZ_API_KEY=             # postiz_xxxxxxxxxxxx
```

**Validation.** "Using the Postiz MCP, list my connected social channels." Expect JSON with ≥1 channel id.

**Gotchas.**
- Downstream platform rate limits pass through.
- First-time OAuth still requires Meta/X/LinkedIn developer apps.
- Self-hosted = you handle token refresh failures. Check queue weekly.
- MCP tool surface lags web UI by a release or two.

**Maintenance.** Gitroom (Nevo David). Very active late 2025, weekly releases, 20k+ stars. AGPL-3.0 + commercial license.

**Links.**
- Source: https://github.com/gitroomhq/postiz-app
- Docs: https://docs.postiz.com
- MCP: https://github.com/gitroomhq/postiz-app/tree/main/libraries/mcp

---

### Recipe: Facebook (Pages + Ads) — REVISED for MCP-first

**What it is.** Meta Graph API access split across three paths by concern: **publishing** (Postiz MCP), **Meta Ads** (community MCP, MCP-backed), **Insights and edge cases** (Bash + direct Graph API, Claude-Code-only).

**Since Jan 2026 update:** Maintained Meta Marketing API MCPs now exist: `brijr/meta-mcp`, `pipeboard-co/meta-ads-mcp` (Meta Business Partner badged), `hashcott/meta-ads-mcp-server`. Solo founders running ads should use one of these — no longer Bash-only.

**Unlocks.** Facebook Page posts (text, image, video, link), scheduling (up to 6 months), Page insights, Ads creation/reporting. Activities: "daily FB page post," "boost winning post," "weekly page insights," "ad set performance check."

**Capabilities.**
- Write: Page feed posts, photo/video upload, scheduling, comment replies, post deletion
- Read: page_impressions, page_engaged_users, per-post reach, follower demographics; ad spend/CTR/CPM/CPA via Marketing API

**Opinionated pick.** Route everything through Postiz for publishing. Only spin up direct Meta Graph if you need Ads (Marketing API) or Insights Postiz doesn't surface. For direct, use Meta Graph API with Page access token. No third-party MCP worth recommending (hobby-grade, abandoned).

**Install.**
1. developers.facebook.com/apps → Create App → Business.
2. Add products: Facebook Login for Business, Pages API, Marketing API (if ads).
3. App Review → request `pages_show_list`, `pages_read_engagement`, `pages_manage_posts`, `pages_read_user_content`. 5-15 business days. Screencast required.
4. Graph API Explorer → select Page → generate long-lived Page Access Token (60 days; convert to System User for permanence).
5. Store in Postiz or `.env`.

**.env:**
```
META_APP_ID=                # App Dashboard top of page
META_APP_SECRET=            # Settings → Basic → App Secret
FB_PAGE_ID=                 # facebook.com/YourPage → About → Page ID
FB_PAGE_ACCESS_TOKEN=       # Long-lived. Refresh every 60 days or use System User token
```

**Validation.** `curl "https://graph.facebook.com/v19.0/$FB_PAGE_ID?access_token=$FB_PAGE_ACCESS_TOKEN"` → name + id.

**Gotchas.**
- App Review is the hard gate. Without it, post only to Pages where you're admin of the developer app.
- Page Access Tokens expire every 60 days. Convert to System User for no-refresh.
- Instagram publishing uses the same app + Instagram Graph API product added.
- Business Verification required for Marketing API.

**Maintenance.** Meta's own API. Graph API version bumps ~quarterly, breaking changes ~24mo with 2yr deprecation.

---

### Recipe: Instagram

**What it is.** Publishing + insights for IG Business/Creator accounts via Instagram Graph API — same Meta app as Facebook.

**Unlocks.** IG feed posts, Reels, Stories (limited), carousels, insights, hashtag search. Activities: "daily Reel," "weekly IG insights," "comment triage," "hashtag research."

**Capabilities.**
- Write: single image, carousel, video, Reels; captions; scheduled via Postiz or Meta Business Suite
- Read: reach, impressions, saves, profile_visits, follower_count, per-post engagement, hashtag search, mentions

**Opinionated pick.** Same as Facebook — Postiz for publishing, Meta Graph API direct for insights/extras. **Uses the same Meta developer app as Facebook.** IG must be linked to a Facebook Page (hard Meta requirement).

**Alternatives rejected.** Later/Buffer (SaaS duplicative). Instagrapi (TOS violation, ban risk). Hobby MCPs (private-API based, unsafe).

**Install.**
1. Convert IG to **Business** or **Creator** (Profile → Settings → Account type). Personal accounts cannot use Graph API.
2. Link IG to a Facebook Page (Page Settings → Linked Accounts → Instagram). Non-negotiable.
3. In the Meta app from the Facebook recipe, add **Instagram Graph API** product.
4. App Review: `instagram_basic`, `instagram_content_publish`, `instagram_manage_insights`, `instagram_manage_comments`.
5. Get IG Business Account ID: `GET /{page-id}?fields=instagram_business_account` with Page token.
6. Connect IG in Postiz (reuses Meta app). Direct: same Page token.

**.env:**
```
IG_BUSINESS_ACCOUNT_ID=     # From /{page-id}?fields=instagram_business_account. 17-digit.
# Reuses META_APP_ID, META_APP_SECRET, FB_PAGE_ACCESS_TOKEN
```

**Validation.** `curl "https://graph.facebook.com/v19.0/$IG_BUSINESS_ACCOUNT_ID?fields=username,followers_count&access_token=$FB_PAGE_ACCESS_TOKEN"`

**Gotchas.**
- Reels upload is async two-step (create container → publish). 30-60s poll loop.
- Stories publishing via API is partner-gated. Assume no.
- 25 API-published posts per IG account per 24h.
- No DM send from API unless Messaging partner (high bar).
- Hashtag search: 30 queries / 7 days / user.

---

### Recipe: LinkedIn

**What it is.** LinkedIn Marketing Developer Platform for personal posts (UGC API), Company Page posts, and Newsletters — OAuth-gated.

**Unlocks.** Personal profile posts, Company Page posts, Newsletters, post analytics, Ads API. Activities: "daily LinkedIn post," "weekly newsletter," "Company Page digest," "comment-engagement sweep."

**Capabilities.**
- Write: UGC posts (text, image, video, article share) to personal OR Company Page; newsletters via Articles API (if approved)
- Read: post impressions, unique impressions, clicks, reactions, comments, shares; Company Page follower demographics

**Opinionated pick.** Postiz for personal + Company Page. LinkedIn's API is the most gatekept — Marketing Developer Platform access is a 1-3 week partner application, sometimes rejected for solo devs. Postiz already holds it, so you ride on their approval. Go direct only if Postiz lacks a feature (e.g., Newsletters API).

**Alternatives rejected.** Direct LinkedIn API (gate too high for v1 solo). Taplio/AuthoredUp (SaaS, no MCP, opinionated UIs). Unipile (paid, another auth layer). Phantombuster (scraper, TOS risk).

**Install.**
1. Deploy Postiz first.
2. Postiz → Channels → Add LinkedIn → OAuth to personal account.
3. For Company Page: you must be **Super Admin** of the Page; Postiz re-prompts for page scope.
4. (Direct only) linkedin.com/developers/apps → Create app → associate to Company Page → request `w_member_social`, `r_liteprofile`, `r_emailaddress`, `w_organization_social` + "Share on LinkedIn" + "Marketing Developer Platform."

**.env:**
```
# Recommended: no LinkedIn-specific vars — Postiz handles the token.
# Direct-only fallback:
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=
LINKEDIN_ACCESS_TOKEN=      # 60-day expiry. refresh_token 1-year capped.
LINKEDIN_ORG_URN=           # urn:li:organization:<id>
```

**Validation.** Via Postiz: "List my LinkedIn channels." Direct: `curl -H "Authorization: Bearer $LINKEDIN_ACCESS_TOKEN" https://api.linkedin.com/v2/userinfo`

**Gotchas.**
- Tokens expire 60 days. refresh_token 1-year capped. Re-auth yearly is unavoidable.
- Company Page posting requires Super Admin.
- Newsletters API is **invite-only** as of Jan 2026 — don't plan on it for v1.
- Video >200MB needs multi-part upload.
- Bursty posting gets flagged. <5 posts/day/account.

**Maintenance.** LinkedIn's own API; stable but bureaucratic. `LinkedIn-Version: 202501` header.

---

### Recipe: Twitter / X

**What it is.** X API v2, paid developer tier (Basic $200/mo minimum for write) for posting, reading, analytics.

**Unlocks.** Tweet, reply, thread, quote, DM (paid tiers), analytics, search. Activities: "daily tweet batch," "reply-guy engagement," "thread publish," "keyword listening."

**Capabilities.**
- Write: tweets + media, threads, replies, quote tweets, scheduled via Postiz, delete
- Read: tweet metrics (your own), user lookup, recent search (7-day Basic, full archive Pro+), mentions timeline

**Opinionated pick.** Postiz for publishing. For reading/search, X API v2 direct via **Basic tier ($200/mo)** — no good free MCP post-2023 API crackdown. If $200/mo can't be justified, **skip X automation entirely in v1** and post manually. Do not use scrapers (bannable).

**Alternatives rejected.** Typefully (SaaS, publishing only). Tweepy hobby MCP (still needs creds anyway). Nitter (shut down). Free tier (1500 posts/mo write-only, no read — too crippled).

**Install.**
1. developer.x.com/en/portal/dashboard → sign in with posting account.
2. Create Project + App. New accounts sometimes get 48-hour review.
3. Subscribe to **Basic ($200/mo)** for read+write.
4. Enable OAuth 2.0 with PKCE; set redirect URI.
5. User auth settings: Read and write (+ DMs if needed).
6. Generate API Key, API Secret, Bearer Token, plus OAuth2 user access token.
7. Postiz channel add or `.env`.

**.env:**
```
X_API_KEY=
X_API_SECRET=
X_BEARER_TOKEN=             # app-only
X_ACCESS_TOKEN=             # user-context OAuth 2.0
X_ACCESS_TOKEN_SECRET=      # OAuth 1.0a for some v1.1 endpoints
```

**Validation.** `curl -H "Authorization: Bearer $X_BEARER_TOKEN" "https://api.x.com/2/users/me"`

**Gotchas.**
- Basic tier: 100 posts / 24h per user, 1667 reads / 15 min. Pro is 10× for $5000/mo.
- Media upload via `upload.twitter.com/1.1/media/upload.json` (v1.1 hybrid).
- Threads = sequential posts with `in_reply_to_tweet_id`, no atomic thread endpoint.
- Anti-automation rules enforced; vary templates.
- Tokens don't expire but can be revoked.

**Maintenance.** X's own API. Policy/pricing shifted 3+ times since 2023. Design for API swap.

---

### Recipe: YouTube

**What it is.** Two distinct integrations. **YouTube Data API v3** (Google Cloud OAuth) for uploads + channel management. **browser-use/video-use** for content research / scraping-style interactions.

**Unlocks.** Video upload, metadata edit, playlist management, comments, analytics (via YouTube Analytics API), captions, thumbnails. Activities: "weekly long-form upload," "Shorts post," "comment triage," "competitor content research," "topic/thumbnail research."

**Capabilities.**
- Write (Data API): video upload (resumable), title/description/tags, thumbnail, playlist CRUD, comment reply, captions upload
- Read (Data API): channel stats, video stats (views, likes, avg view duration), search (capped by quota)
- Read (video-use): transcript extraction, visual frame analysis, "watch & summarize," competitor channel pulls without API quota

**Opinionated pick — split:**
- **Publishing + own-channel analytics:** YouTube Data API v3 direct (thin MCP or direct tool). Official, quota-governed, free up to 10k units/day.
- **Content research / competitor intel / transcripts:** `browser-use/video-use`. Python library on `browser-use` agent framework (Playwright browser automation). **Not an MCP out of the box**, requires Chromium. Wrap as local tool or run headless in Docker. Worth it — Data API transcript access is gated, search quota burns fast (100 units/query).

**Alternatives rejected.** yt-dlp (metadata+transcript only, no publish). Apify YT scrapers (paid). TubeBuddy/VidIQ (extensions, no API). Hobby YouTube MCPs (thin Data API wrappers).

**Install.**
1. **Data API v3:** console.cloud.google.com → project → Enable "YouTube Data API v3" + "YouTube Analytics API."
2. OAuth consent: External, add your email as test user.
3. Credentials → Create OAuth 2.0 Client ID → Desktop app.
4. Run local OAuth flow once (oauth2l or 20-line Python) → refresh token in `.env`.
5. **video-use:** `pip install video-use`. `playwright install chromium`. Needs LLM API key (OpenAI/Anthropic).
6. Wrap video-use as local CLI or custom MCP (no published MCP as of Jan 2026).

**.env:**
```
YT_CLIENT_ID=               # Credentials → OAuth 2.0 Client IDs
YT_CLIENT_SECRET=
YT_REFRESH_TOKEN=           # one-time OAuth flow; long-lived
YT_CHANNEL_ID=              # studio.youtube.com → Settings → Channel → Advanced. UC...
ANTHROPIC_API_KEY=          # for video-use LLM loop
```

**Validation.** Data API: `curl "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=$YT_CHANNEL_ID&key=$YT_CLIENT_ID"` or OAuth'd `mine=true`. video-use: `python -c "from video_use import Agent; print(Agent().run('Summarize https://youtu.be/...'))"`

**Gotchas.**
- Data API: 10k units/day. **Upload = 1600 units = ~6 uploads/day cap** without quota increase (free, ~1 week).
- New OAuth apps are quota-locked to unlisted uploads until Google audits — plan to submit for audit before public uploads.
- video-use **runs a real browser** — 500MB+ RAM per session, LLM tokens per action.
- YouTube detects automation. video-use for research/read only; never publish.
- video-use is young (early 2025), small team. Pin a version.

**Maintenance.** Data API: Google, stable, long deprecation. video-use: active but <1 yr old. Experimental.

---

### Cluster 1 notes

**Shared auth.** Facebook + Instagram = **one Meta developer app, one App Review, one Page Access Token.** Instagram recipe explicitly reuses `META_APP_ID` / `FB_PAGE_ACCESS_TOKEN`. One grueling Meta onboarding unlocks two channels.

**Hidden dependencies.**
- LinkedIn Company Page posting requires Super Admin (not just connected account).
- IG Graph API requires Facebook Page link + Business/Creator account — three conversions before any API call.
- YouTube uploads quota-capped to ~6/day until Google audit.

**Defer from v1.** LinkedIn Newsletters API (invite-only). IG Stories API (partner-gated). X direct unless $200/mo committed. Meta Marketing API (needs Business Verification, skip until ads exist).

**Biggest surprise.** Postiz's bundled MCP collapses 5 of 6 social OAuth gauntlets into one Postiz-hosted OAuth session. Single biggest lever for a solo founder. Reason to put Postiz first even though it adds a deploy step.

**YouTube note.** video-use is not an MCP and not a drop-in — agentic browser loop with LLM tokens per navigation. Research only, never as a publishing path.

---

## Cluster 2 — SEO + analytics (3 recipes)

### Recipe: claude-seo

**What it is.** Comprehensive SEO skill-plugin bundling 20 skills (1 orchestrator + 15 always-on + 4 MCP extensions) covering full-site audits, single-page analysis, technical SEO, content/E-E-A-T, schema, sitemaps, local SEO, maps intelligence, hreflang, programmatic SEO, competitor pages, GEO, and integrations with Google's own SEO APIs.

**Ownership.** Author metadata across all `SKILL.md`: `AgriciDaniel`. TODO: verify canonical GitHub URL (likely `github.com/AgriciDaniel/claude-seo`). `seo-image-gen` references companion `github.com/AgriciDaniel/banana-claude`.

**Skills shipped (observed on disk at `~/.claude/skills/seo-*/`).**
- Orchestrator: `seo`
- Always-available: `seo-audit`, `seo-page`, `seo-technical`, `seo-content`, `seo-schema`, `seo-images`, `seo-sitemap`, `seo-geo`, `seo-plan`, `seo-programmatic`, `seo-competitor-pages`, `seo-hreflang`, `seo-local`, `seo-maps`, `seo-google`, `seo-backlinks`
- MCP-dependent: `seo-firecrawl`, `seo-dataforseo`, `seo-image-gen` (Gemini via nanobanana)

**MCP dependencies.**

| Extension skill | MCP server | Install | Required credential |
|---|---|---|---|
| `seo-dataforseo` | DataForSEO MCP (79 tools, 9 modules) | `./extensions/dataforseo/install.sh` | DataForSEO API login + password (MCP config, not skill) |
| `seo-firecrawl` | Firecrawl MCP | `./extensions/firecrawl/install.sh` | `FIRECRAWL_API_KEY` env var |
| `seo-image-gen` | nanobanana MCP (Gemini) | `./extensions/banana/install.sh` | Gemini API key from aistudio.google.com/apikey |
| `seo-backlinks` | Same DataForSEO MCP | — | Same as seo-dataforseo |
| `seo-maps` | DataForSEO tier + free Overpass/Geoapify | — | DataForSEO creds for full tier |

**Credentials pattern for built-in `seo-google`** (no MCP — pure Python + REST):

Config file: `~/.config/claude-seo/google-api.json`:
```json
{
  "service_account_path": "~/.config/claude-seo/service_account.json",
  "api_key": "AIzaSy...",
  "default_property": "sc-domain:example.com",
  "ga4_property_id": "properties/123456789"
}
```

Four credential tiers:
- **Tier 0** (API key only): PSI, CrUX, CrUX History, YouTube Data API, Knowledge Graph, Web Risk, NLP
- **Tier 1** (+ service account JSON): GSC Search Analytics, URL Inspection, Sitemaps, Indexing API
- **Tier 2** (+ `ga4_property_id`): GA4 Data API
- **Tier 3** (+ ads_developer_token + ads_customer_id): Google Ads Keyword Planner

Secrets go in config JSON at `~/.config/claude-seo/`, not env, not `settings.json`. Availability check: `python scripts/google_auth.py --check --json`.

**Install.** TODO: verify marketplace coordinates. `/plugin marketplace add <source>` then `/plugin install claude-seo`. Extensions install separately via `install.sh`.

**Maintenance.** TODO — verify at install time. On-disk skill versions range 1.6.1 to 1.7.2, indicating active development.

---

### Recipe: GSC MCP (Google Search Console)

**What it is.** Programmatic access to Search Analytics (clicks, impressions, CTR, position), URL Inspection (indexation, canonical, mobile, rich results), Sitemaps. GSC is authoritative for how Google sees your site organically — beats any third-party estimator.

**Canonical MCP.** TODO: find canonical. No dominant community MCP has emerged. **Recommended approaches in order:**

1. **claude-seo's `seo-google`** — wraps GSC via Python scripts, no MCP needed. Covers: Search Analytics, URL Inspection (single + batch up to 2,000/day), Sitemaps listing, Indexing API.
2. **Custom thin MCP wrapper** over `google-api-python-client`'s `searchconsole` v1 resource (~100 lines of Python).
3. **DataForSEO partial coverage** via `seo-dataforseo` — SERP data paralleling GSC, but *not* your own property's GSC data.

**API setup.**
1. GCP project: console.cloud.google.com → New Project.
2. Enable APIs: Google Search Console API + Web Search Indexing API.
3. Create service account: IAM & Admin → Service Accounts → `claude-gsc` → Keys → Add Key → JSON → store at `~/.config/claude-seo/service_account.json` (chmod 600).
4. **Grant service account access to each GSC property:** Search Console → property → Settings → Users and permissions → Add user → paste service account `client_email` (looks like `claude-gsc@project-id.iam.gserviceaccount.com`) → **Full** for SA+URL+Sitemaps or **Owner** for Indexing submissions.
5. Property URL format: `sc-domain:example.com` for domain properties, `https://example.com/` for URL-prefix.

**Required OAuth scopes** (service accounts grant implicitly):
- `webmasters.readonly` — SA + URL Inspection + sitemap list
- `webmasters` — sitemap submit/delete
- `indexing` — Indexing API publish/delete

**.env / config.** Custom MCP: `GOOGLE_APPLICATION_CREDENTIALS` → service-account JSON. claude-seo wrapper: everything in `~/.config/claude-seo/google-api.json`. **Secrets in config file, not settings.json.**

**Rate limits.**
- Search Analytics: 1,200 QPM/site, 30M QPD
- URL Inspection: 600 QPM, **hard cap 2,000 per site per day** — plan batch around this
- Indexing API: 380 RPM, 200 publish/day (officially JobPosting + BroadcastEvent/VideoObject only)

**Maintenance.** TODO — verify at install time.

---

### Recipe: GA4 MCP (Google Analytics 4 Data API)

**What it is.** GA4 report data: sessions, users, pageviews, engagement, conversions, revenue, filtered by channel group, date range, dimensions. Replaces deprecated UA Reporting API.

**Canonical MCP.** TODO: find canonical. **Recommended:**

1. **claude-seo's `seo-google`** already ships GA4 (`/seo google ga4`, `/seo google ga4-pages`) via `google-analytics-data` Python client. If you installed claude-seo, you have GA4.
2. **Custom thin MCP** over `google-analytics-data` (pypi) or `@google-analytics/data` (npm). `runReport` is the 90% call.
3. Avoid third-party aggregators — middleman for data you can read directly.

**API setup.**
1. GCP project: reuse GSC project.
2. Enable API: Google Analytics Data API.
3. Service account: reuse from GSC, or create new the same way.
4. **Grant GA4 property access:** analytics.google.com → Admin (gear, bottom left) → Property column → **Property Access Management** → + → paste `client_email` → Role: **Viewer** (sufficient for `runReport`).
5. **Find Property ID:** Admin → Property Details → numeric like `123456789`. API expects `properties/123456789`.

**Required OAuth scope:** `analytics.readonly`

**.env / config.** `GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json`. `GA4_PROPERTY_ID=properties/123456789` per claude-seo pattern in `~/.config/claude-seo/google-api.json`.

**Canonical first query.** Organic Search sessions, last 28 days, by landing page:
```
dimensions: [{name: "landingPagePlusQueryString"}, {name: "sessionDefaultChannelGroup"}]
metrics: [{name: "sessions"}, {name: "engagedSessions"}, {name: "conversions"}]
dateRanges: [{startDate: "28daysAgo", endDate: "today"}]
dimensionFilter: { filter: { fieldName: "sessionDefaultChannelGroup", stringFilter: { value: "Organic Search" }}}
```

**Rate limits.** 10 concurrent requests per property. Per-project daily token budget (~25K tokens/day free tier; complex reports burn more). 429 on quota; exp backoff.

**Maintenance.** TODO — verify at install time.

---

### Cluster 2 notes

**How these three fit.** claude-seo is the orchestrator and ships GSC + GA4 via its `seo-google` sub-skill. For most users, "GSC MCP" and "GA4 MCP" recipes are about augmenting/replacing features already in claude-seo, not adding missing functionality. Recommend claude-seo first; reach for custom/standalone only if (a) MCP-native tool calls in other clients, or (b) skip the rest of claude-seo.

**Credential pattern — all three share.** One GCP project, one service-account JSON, one API key covers GSC + GA4 + PageSpeed + CrUX + Indexing. Service-account `client_email` must be added as a user in EACH GSC property AND EACH GA4 property. Most common gotcha — valid SA with no per-property grants returns 403s that look like auth failures.

**Secrets hygiene.** claude-seo → `~/.config/claude-seo/google-api.json`. Custom MCP → `GOOGLE_APPLICATION_CREDENTIALS` env-var convention. Never commit service-account JSON. Never in shared settings.json.

**DataForSEO as substitute.** If user cannot set up GCP creds (agency without property owner access), DataForSEO's `seo-dataforseo` provides SERP-side visibility as fallback — but it's *external* data (public rankings) not *internal* (what owner sees in GSC). Complementary, not interchangeable.

**Install order.** (1) claude-seo core → (2) GCP project + SA + API key + config file → (3) grant SA to GSC and GA4 properties → (4) `/seo google setup` credential check → (5) optional DataForSEO + Firecrawl → (6) optional nanobanana.

**Source files cited.** `/Users/johndavenport/.claude/skills/seo/SKILL.md`, `/Users/johndavenport/.claude/skills/seo-google/SKILL.md`, `/Users/johndavenport/.claude/skills/seo-google/references/auth-setup.md`, plus `seo-dataforseo`, `seo-firecrawl`, `seo-image-gen` SKILL.md files.

---

## Cluster 3 — Content + CRM + revenue + email (4 recipes)

### Recipe: WordPress — REVISED to MCP-first

**Upgrade from earlier draft.** WordPress now has a clean official MCP story as of April 2026. Moves from ⚠️ Bash fallback to first-class MCP-first recipe.

**Architecture (two-piece):**

1. **Server-side (on the WP site):** `WordPress/mcp-adapter` — official WordPress.org-maintained PHP library, installed as a WordPress plugin. 931 stars, v0.5.0 (2026-04-15), actively developed. Exposes WordPress Abilities API over MCP.
2. **Client-side (on the user's machine):** `@automattic/mcp-wordpress-remote` — Node.js MCP server from Automattic. 134 stars but 119 commits, actively maintained. Runs locally via `npx`, proxies to the WP site.

**Deprecated / dead — DO NOT USE:**
- `Automattic/wordpress-mcp` — archived July 2025, explicitly deprecated in favor of mcp-adapter
- `mcp-wp/mcp-server`, `mcp-wp/ai-command` — both archived Dec 2025, hackathon origin

**What it is.** Full MCP read/write to a WordPress site's content, users, WooCommerce store, and settings via OAuth 2.1.

**Unlocks.** Owned blog, SEO content engine, announcement hub. Activities: "draft weekly post from cluster notes," "audit top-10 posts by traffic intent," "update CTA on pillar pages," "cross-link new post into existing cluster."

**Capabilities.**
- Write: create/update/delete posts, pages, categories, tags, media, featured images, status (draft/publish/scheduled)
- Read: list posts with filters (author, category, date, search), taxonomies, site structure, users, page hierarchy, revisions

**Opinionated pick.** `WordPress/mcp-adapter` (server-side plugin) + `@automattic/mcp-wordpress-remote` (client-side MCP). OAuth 2.1 default. Works for both self-hosted WP and WordPress.com.

**Capabilities (via mcp-wordpress-remote):**
- Posts/pages CRUD
- Users management
- Settings access
- WooCommerce: customers, products, orders
- Resource metadata discovery
- General WP REST API passthrough

**Install.**
1. **On the WP site (one-time, requires admin):**
   - WP Admin → Plugins → Add New → upload `WordPress/mcp-adapter` (or install via Composer if WP-CLI is available: `wp plugin install mcp-adapter`).
   - Activate. Adapter exposes `/wp-json/wp/v2/mcp/` endpoints.
2. **Locally (on user's machine):**
   - `claude mcp add --transport stdio wordpress -s user -- npx -y @automattic/mcp-wordpress-remote`
   - Set `WP_API_URL` env to the site URL.
3. First call: triggers OAuth 2.1 browser flow → user authorizes → token cached locally by mcp-wordpress-remote.

**.env (minimal — most auth is OAuth-managed):**
```
WP_API_URL=             # https://yoursite.com (no trailing slash)
# Fallbacks if NOT using OAuth (self-hosted only):
WP_API_USERNAME=        # WP admin username (Application Passwords path)
WP_API_PASSWORD=        # 24-char Application Password
```

**Validation.** "Using the WordPress MCP, list my 5 most recent posts." Expect post IDs + titles.

**Gotchas.**
- **Server-side install requires WP admin access.** If user is on managed WP (WP Engine, Kinsta), confirm plugin install permissions before proceeding.
- WordPress.com — only Business plan and up support arbitrary plugin install. Personal/Premium plans must use OAuth-only path against WP.com's hosted endpoints (mcp-wordpress-remote handles this).
- `mcp-adapter` requires WordPress 6.6+ for full Abilities API support.
- Plain-HTTP sites won't work with OAuth — HTTPS required.
- Security plugins (Wordfence, iThemes) may block `/wp-json/wp/v2/mcp/` — whitelist if needed.
- WooCommerce tools only available if WooCommerce is active on the site.

**Maintenance.**
- `WordPress/mcp-adapter` — official WordPress.org, v0.5.0 Apr 2026, 931 stars, AI Building Blocks initiative. Will be the long-term standard.
- `@automattic/mcp-wordpress-remote` — Automattic, 134 stars, 119 commits, no formal releases yet but active.

**Links.**
- Adapter (server): https://github.com/WordPress/mcp-adapter
- Remote (client MCP): https://github.com/Automattic/mcp-wordpress-remote
- npm: https://www.npmjs.com/package/@automattic/mcp-wordpress-remote

---

### Recipe: HubSpot

**What it is.** Read-first CRM access; write-back for touchpoint logging.

**Unlocks.** CRM intelligence, lifecycle email triggers, attribution. Activities: "Monday funnel review — new contacts, stage changes, stalled deals," "log this newsletter send as engagement," "segment by lifecycle for next campaign," "identify cold MQLs for re-engagement."

**Capabilities.**
- Read (primary): contacts + properties, lifecycle stage, deal pipeline + stages, engagements (emails, meetings, calls, notes), companies, lists, forms, marketing events, UTM/source properties
- Write (secondary): create/update contacts, create engagements (notes, emails, tasks), update deal stage, associate contacts to companies/deals

**Opinionated pick.** Private App access token. Scoped, revocable, no OAuth dance. Free CRM tier supports it.

**Alternatives rejected.** OAuth2 app (overkill for single-user). Legacy hapikey (deprecated Nov 2022). Community HubSpot MCP (viable, Private App token underneath).

**Install.**
1. HubSpot → Settings (gear) → Integrations → Private Apps → Create.
2. Name `claude-market-stack`. Scopes: `crm.objects.contacts.read/write`, `crm.objects.deals.read/write`, `crm.objects.companies.read`, `crm.schemas.contacts.read`, `crm.lists.read`, `sales-email-read`, `tickets.read` if used.
3. Create → Show token → copy.
4. Save to `.env`.

**.env:**
```
HUBSPOT_PRIVATE_APP_TOKEN=   # pat-na1-... Bearer
HUBSPOT_PORTAL_ID=           # numeric hub ID, top-right of UI
```

**Validation.** `curl -H "Authorization: Bearer $HUBSPOT_PRIVATE_APP_TOKEN" "https://api.hubapi.com/crm/v3/objects/contacts?limit=1"` → `{"results":[{...}]}` with ≥1 contact.

**Gotchas.**
- Free + Starter: 100 req / 10 sec, 250k req/day per portal. Use `limit=100` + `after` cursor.
- Search API stricter: 5 req/sec, max 10,000 results per query.
- `lifecyclestage` forward-only by default; demote by setting empty first.
- Engagements v1 legacy; prefer v3 `/crm/v3/objects/emails`.
- Free tier no marketing-email send API — read/segment only.

**Maintenance.** HubSpot. v3 CRM stable, versioned, 6+ month deprecation notices.

---

### Recipe: Stripe

**What it is.** Read-only, marketing-relevant slice for weekly sub + MRR intelligence. Not finance.

**Unlocks.** Revenue intelligence, attribution, pricing experiments. Activities: "Monday revenue standup — net new, churn, MRR delta," "map new subs to UTM source via Checkout metadata," "flag price-point experiments that moved conversion," "trials ending this week."

**Capabilities.**
- Read only:
  - New subs: `GET /v1/subscriptions?created[gte]=<ts>&status=active` — count by week
  - Churn: `subscriptions?status=canceled&canceled_at[gte]=<ts>`
  - MRR + trend: Sigma queries, or derive from `subscription_items.price.unit_amount * quantity` summed across active
  - Attribution: `Checkout.Session.metadata` or `Customer.metadata` with `utm_source`, `utm_campaign`
  - Trials ending: `subscriptions?status=trialing` + `trial_end` filter
  - Cohort: Sigma `subscriptions` table

**Opinionated pick.** Stripe Restricted API Key (read-only scope). Same-account, no OAuth, scoped to what a marketer needs. Official Stripe MCP wraps this cleanly.

**Alternatives rejected.** Full secret key (blast radius). Stripe Connect OAuth (platforms only). Sigma exports (good complement for complex MRR, not replacement).

**Install.**
1. Stripe Dashboard → Developers → API keys → Create restricted key `market-stack-read`.
2. READ on: Customers, Subscriptions, Invoices, Checkout Sessions, Charges, Products, Prices, Coupons, Promotion Codes. Everything else None.
3. Copy `rk_live_...` (or `rk_test_...`).
4. `.env`.

**.env:**
```
STRIPE_RESTRICTED_KEY=   # rk_live_... read-only
STRIPE_ACCOUNT_ID=       # acct_... optional (Connect)
```

**Validation.** `curl -u "$STRIPE_RESTRICTED_KEY:" "https://api.stripe.com/v1/subscriptions?limit=1&status=active"` → `{"object":"list","data":[...]}`.

**Gotchas.**
- 100 read req/sec live, 25/sec test. Paginate via `starting_after`.
- MRR not first-class — derive from active subs or Sigma `subscriptions` + `prices` join.
- Attribution requires metadata set at Checkout creation. Retrofit impossible.
- `canceled_at` ≠ `ended_at`. First is user click, second is access lapse.
- Multi-currency accounts need FX normalization (smallest unit = cents).

**Maintenance.** Stripe. Date-versioned, extremely stable. Official MCP shipped 2025.

**Links.** https://github.com/stripe/agent-toolkit

---

### Recipe: BillionMail (v2 — deferred)

**Status:** Infrastructure-ready, automation gap. No public REST API, no MCP as of Jan 2026. **Not shipping in v1.**

**V1 replacement:** Resend (SaaS) — has Broadcasts for campaigns. User already uses Resend.

**Fallback if self-hosting required in v1:** Listmonk — mature JSON REST API, active since 2019, easy Docker deploy.

**When BillionMail goes v1:** when (a) public REST API lands, or (b) we write a thin MCP wrapper over web UI / Postgres schema.

(Note for research file: full BillionMail setup notes preserved in draft for v2 revisit — abbreviated here.)

---

### Recipe: Resend (V1 — replacement for BillionMail)

**What it is.** SaaS transactional + broadcast email via REST API. Already in use by user.

**Unlocks.** Transactional email, newsletters, broadcast campaigns. Activities: "send weekly newsletter," "broadcast product announcement," "send Stripe-triggered lifecycle email."

**Capabilities.**
- Write: send single email, send batch, Broadcasts (bulk campaigns), Audiences (contact lists), React Email templates
- Read: delivery logs, open/click events (webhooks), audience membership

**Gap flagged.** Multi-step drip automation (workflows) is in beta as of Jan 2026. For trigger-based drip sequences, add ConvertKit or Customer.io. Not needed for v1.

**If Ghost is installed:** Newsletter sends happen in Ghost, not Resend. Resend's role narrows to customer lifecycle + transactional.

**Install.** TODO: verify current onboarding URL (resend.com/signup → API Keys).

**.env:**
```
RESEND_API_KEY=         # re_... from resend.com → API Keys
RESEND_FROM_EMAIL=      # verified sender domain
RESEND_AUDIENCE_ID=     # optional, for Broadcasts
```

**Validation.** `curl -X POST https://api.resend.com/emails -H "Authorization: Bearer $RESEND_API_KEY" -H "Content-Type: application/json" -d '{"from":"$RESEND_FROM_EMAIL","to":"you@example.com","subject":"Test","html":"<p>works</p>"}'` → returns `{"id":"..."}`.

---

### Recipe: Wix (V1 — added from research, best recipe we have)

**What it is.** Wix sites via the **official Wix MCP Server**, which is a **native built-in connector in Claude** — no install step, no `.env` credentials, Wix handles OAuth and runs the MCP on their own infrastructure with 24/7 SOC monitoring.

**Unlocks.** Wix-hosted content sites + e-commerce + CRM in one integration. Activities: "draft weekly blog post and save as Wix draft," "audit Wix store product catalog," "review new Wix contacts this week," "check bookings pipeline," "update blog post SEO fields."

**Capabilities.**
- Write: blog posts + drafts, CRM contacts (create/update), store product edits (where exposed), booking services
- Read: Wix API + SDK docs (self-documenting), blog content, store products + inventory, customer orders, contacts, bookings

**Opinionated pick.** Wix's official MCP Server. Zero competition — this is the vendor's own, supported, monitored. Built-in Claude connector means **Claude Desktop users get the same experience as Claude Code users** — exactly the portability win we want from the MCP-first rule.

**Alternatives considered.**
- Wix REST API direct — unnecessary; official MCP wraps it.
- Community Wix scrapers — avoid.

**Install.**
1. In Claude Desktop / Claude Code → Settings → Connectors → **Wix**. Enable.
2. OAuth to your Wix account when prompted.
3. Grant the specific Wix site(s) you want exposed.
4. Done.

**.env:** None. The connector manages auth.

**Validation.** Ask Claude: "Using the Wix connector, list my 5 most recent blog drafts." Expect JSON/table with draft IDs and titles.

**Gotchas.**
- Native connector only — if a user wants programmatic (non-Claude) access, they need to use Wix REST API directly (different setup, not our recipe).
- Scoped per-site — if user has multiple Wix sites, authorize each separately.
- Wix Studio features (the newer dev-oriented product) have fuller MCP coverage than classic Wix Editor sites.

**Maintenance.** Wix. Enterprise-tier maintenance; native Claude integration means Anthropic + Wix both have skin in the game for uptime.

**Links.**
- Wix MCP: https://www.wix.com/studio/developers/mcp-server
- About the MCP: https://dev.wix.com/docs/api-reference/articles/wix-mcp/about-the-wix-mcp
- Wix's Claude Code blog post: https://medium.com/wix-engineering/turning-claude-code-into-a-management-platform-that-empowers-my-team-99d6677152bb

---

### Recipe: Ghost (V1 — added from research)

**What it is.** Ghost CMS via `@fanyangmeng/ghost-mcp` — read/write to a Ghost blog covering posts, members, newsletters, tiers, offers, tags, users, webhooks.

**Unlocks.** Content publishing + native newsletter + paid memberships fused. For solo founders doing blog + newsletter + subscription revenue, Ghost replaces WordPress + a separate email tool + a separate memberships tool. Activities: "draft weekly newsletter," "publish post + trigger member send," "audit tier performance," "create limited-time offer."

**Capabilities.**
- Write: Posts (CRUD), Members (CRUD), Newsletters (CRUD), Offers (CRUD), Tags (CRUD), Tiers (CRUD), Users (edit/delete), Webhooks (create/delete)
- Read: all of the above + Roles (read-only), Invites (browse)

**Opinionated pick.** `MFYDev/ghost-mcp` (published as `@fanyangmeng/ghost-mcp` on npm). TypeScript, MIT, 173 stars, v0.2.0 released 2026-04-19 (active).

**Alternatives considered.** `hieunguyenzzz/mcp-ghostcms` (viable, less comprehensive). Direct Ghost Admin API (JWT-signed, doable but the MCP already wraps it).

**Install.**
1. Ghost Admin → Integrations → Add custom integration → name `claude-market-stack` → copy Admin API Key.
2. Claude MCP: `claude mcp add --transport stdio ghost -s user -- npx -y @fanyangmeng/ghost-mcp` (or add to `.mcp.json` with env mapping).
3. Reference env vars via `.mcp.json` `env` block pointing at `.env`.

**.env:**
```
GHOST_API_URL=           # https://yourblog.com (no trailing slash)
GHOST_ADMIN_API_KEY=     # id:secret format, 26-char id + 64-char hex secret, from Ghost integration page
GHOST_API_VERSION=       # v5.0 (pin; bump when your Ghost major version moves)
```

**Validation.** Ask Claude: "Using the Ghost MCP, list the last 5 posts." Should return JSON with `id`, `title`, `slug`, `published_at`.

**Gotchas.**
- Admin API Key is in `id:secret` format — copy the whole string including the colon.
- No rate limits documented; Ghost's Admin API is generous but assume ~100 req/min.
- Newsletter send triggers on post-publish by default — distinguish "publish + email" from "publish only" via the `email_recipient_filter` field.
- Admin API does not support member password reset; use the Ghost UI for that.

**Maintenance.** MFYDev (Fan Yang). TypeScript 92.9%. Last commit (v0.2.0): 2026-04-19.

**Links.**
- Source: https://github.com/MFYDev/ghost-mcp
- npm: https://www.npmjs.com/package/@fanyangmeng/ghost-mcp
- Ghost Admin API: https://ghost.org/docs/admin-api/

---

### Cluster 3 notes

**HubSpot × Stripe identity resolution.** The hinge is email. Stripe `Customer.email` is the join into HubSpot contacts. Two practical moves: (1) set `metadata[hubspot_contact_id]` on every Stripe Customer at checkout creation → O(1) reverse lookup. (2) mirror `stripe_customer_id` as custom contact property in HubSpot. With both, Claude can answer "which MQLs converted to paid this month, at what MRR?" in one pass — the real marketing + revenue loop. Without instrumentation at checkout, identity resolution is probabilistic email-matching, misses ~10-20% (plus addresses, aliases, Stripe Link guest checkouts).

**BillionMail v2, not v1.** Ship v1 with Resend as default SaaS, Listmonk as self-host. Add BillionMail when API ships.

**Content-infra gap.** Add Ghost to v1 alongside WordPress. Defer Notion-CMS to v1.1. Skip Sanity/Contentful (overkill for solo).

---

## Cluster 4 — Reddit + ecosystem sweep

### Recipe: Reddit

**What it is.** Reddit browsing + search + user/thread analysis via `reddit-mcp-buddy` MCP server.

**Unlocks.** Reddit channel: listening, research, and (via browser/manual layer) posting. Activities: "daily Reddit scan for empathy threads in target subs," "competitor/persona user-profile research," "weekly subreddit trend check," "find threads where my product is a genuine answer," "draft comment with context."

**Capabilities.**
- Read / intelligence: `browse_subreddit` (hot/new/top/rising/controversial), `search_reddit` (query, author, time, flair), `get_post_details` (full comment tree), `user_analysis` (karma, posts, comments, active subs), `reddit_explain` (terminology)
- Write: **None.** The MCP is read-only by design. Posting/commenting is a separate concern — best done through Postiz (which supports Reddit) or manually. This matches the `reddit-linking-playbook.md` principle of "John dictates, AI polishes — never post AI drafts verbatim."

**Opinionated pick.** `karanb192/reddit-mcp-buddy`. 621 stars, active (v1.1.12 Feb 2026), MIT-friendly, three-tier auth. Clean install via `npx`.

**Alternatives considered.**
- Direct Reddit API via PRAW (Python) — viable but no MCP wrapper; reinventing what reddit-mcp-buddy already does
- Redditwarp, snoowrap — library-level, not MCP
- Scrapers — bannable and redundant

**Install.**
1. (Optional but recommended for 60 or 100 rpm.) Create a Reddit app at https://www.reddit.com/prefs/apps → click "create another app" → select **script** type for 100 rpm authenticated, or **web app** for 60 rpm app-only → note Client ID (under app name) + Client Secret.
2. `claude mcp add --transport stdio reddit-mcp-buddy -s user -- npx -y reddit-mcp-buddy`
3. Add env vars to `.env` (or skip for anonymous 10 rpm).
4. Reference `.env` from `.mcp.json` env block for the `reddit-mcp-buddy` entry.

**.env (one of three tiers — pick the highest you can sustain):**
```
# Tier 1 (anonymous, 10 rpm) — no vars needed

# Tier 2 (app-only, 60 rpm)
REDDIT_CLIENT_ID=            # 14-char from Reddit app page, under the app name
REDDIT_CLIENT_SECRET=        # 27-char from Reddit app page, "secret"

# Tier 3 (authenticated, 100 rpm) — adds:
REDDIT_USERNAME=             # the account that created the script app
REDDIT_PASSWORD=             # account password (consider a dedicated bot account)
```

**Validation.** "Using reddit-mcp-buddy, browse r/elixir hot, 3 posts." Expect JSON with title, author, url, score.

**Gotchas.**
- Rate limits are honest — 10/60/100 rpm by tier. Pacing matters for the daily scan activity.
- Auth caching: 15min TTL anonymous, 5min authenticated — fine for a scan rotation, watch for staleness if doing minute-precision work.
- `search_reddit` with very broad queries can burn rate-limit; always add a subreddit filter when possible.
- Reddit account that auths the script app should not be your personal one — create a dedicated "tools" account, reduce risk of auth lockout if Reddit flags automation.
- The MCP provides NO posting capability. Posting goes through Postiz (Reddit is supported there) or manual.

**Maintenance.** karanb192. Active, v1.1.12 Feb 2026. Docker image available.

**Links.**
- Source: https://github.com/karanb192/reddit-mcp-buddy
- Reddit app setup: https://www.reddit.com/prefs/apps

---

### `marketingskills` plugin audit

**Repo:** https://github.com/coreyhaines31/marketingskills
**Author:** Corey Haines (Conversion Factory / Swipe Files)
**Scale:** 22.8k stars, 3.7k forks, 2 open issues, v1.8.0 released 2026-04-21 (yesterday). Heavily adopted, actively maintained.
**Architecture:** 40 markdown skills across 7 categories. **Zero MCP dependencies.** Pure playbook/prompt engineering.

**Skills inventory:**

| Category | Skills |
|---|---|
| Conversion Optimization | page-cro, signup-flow-cro, onboarding-cro, form-cro, popup-cro, paywall-upgrade-cro |
| Content & Copy | copywriting, copy-editing, cold-email, email-sequence, social-content |
| SEO & Discovery | seo-audit, ai-seo, programmatic-seo, site-architecture, competitor-alternatives, schema-markup |
| Paid & Distribution | paid-ads, ad-creative, social-content |
| Measurement & Testing | analytics-tracking, ab-test-setup |
| Retention | churn-prevention |
| Growth & Strategy | free-tool-strategy, referral-program, marketing-ideas, marketing-psychology, launch-strategy, pricing-strategy, revops, sales-enablement, product-marketing-context, customer-research, content-strategy, competitor-profiling, directory-submissions, lead-magnets, aso-audit |

**Overlap analysis.**

This is not a competitor — it's a **complementary layer.** Corey Haines' skills are "how to think about [marketing activity]" — markdown playbooks, no tooling. `market-my-spec` is fundamentally different:

- `marketingskills` = the thinking layer (strategy, psychology, CRO playbooks, copy frameworks)
- `market-my-spec` strategy skill = project-specific strategy (your ICP, your positioning, your 90-day plan)
- `market-my-spec` daily-plan = execution orchestrator
- `market-stack` (this project) = **the infrastructure layer** — wire up the APIs, MCPs, credentials, and config that turn generic playbooks into actually-running activities

**Recommendation:** `/market-stack` should **explicitly install `marketingskills` as a recommended companion** in a "setup complete, now install these" step. The playbooks in `marketingskills` will often be the *referenced skill* for an activity created by `/daily-plan` — e.g., a daily activity "draft a cold-email sequence" points at `/cold-email` from marketingskills, while `market-stack` ensures Resend/HubSpot are configured for the send.

**What we do NOT duplicate:**
- All 40 playbook skills — we don't compete with playbook craft
- `seo-audit`, `programmatic-seo`, `schema-markup` — claude-seo covers these with actual API-backed data, and marketingskills covers the methodology. Orthogonal.

**What we DO own that marketingskills doesn't:**
- Strategy interview (ours is a guided 8-step with research agents; theirs is playbook references)
- Daily operating rhythm + activity roster (new category)
- Infrastructure setup (new category)
- Skill/activity lifecycle management (archival, scaffolding)

---

### V2 candidates found during sweep

All viable, all deferred from v1 to keep scope tight.

| Tool | Channel | MCP status | Fit | Notes |
|---|---|---|---|---|
| **Beehiiv** (official MCP) | Newsletter | Native, paid plans, early access (beehiiv.com/features/mcp) | High | Beehiiv users get first-class. If Ghost isn't your choice, this is. **Beehiiv OR Ghost, not both.** |
| **Discord MCP** | Community | Multiple strong options: `glittercowboy/discord-mcp` (128 ops), `HardHeadHackerHead/discord-mcp` (134 tools) | High if community is inner-ring | v2 — community channels are rarely day-1 infrastructure |
| **Adspirer** | Paid ads | Official Claude Code marketplace plugin | Medium | Google/Meta/LinkedIn/TikTok ads from Claude. V2 because "no ad budget yet" is the default at market-stack v1. |
| **Synter MCP** | Paid ads (Meta) | Per vendor blog | Medium | Meta-focused alternative to Adspirer. Pick one in v2. |
| **Mirra MCP** | Content + publishing | 24 tools, SaaS-backed | Low | Proprietary middleman; prefer direct integrations when we already own them (Postiz, Ghost). |
| **Shopify MCP** | Commerce | Official per Shopify's docs | High (if e-commerce) | Out of beachhead for a dev-tool founder. Add when a DTC/ecom user joins. |
| **Apify scrapers (generic)** | Research / content | Apify MCP | Medium | Useful for competitive content pulls; browser-use/video-use covers similar territory. |
| **Notion MCP** | Knowledge / CMS | Official Notion MCP | Medium | CMS alternative to WordPress/Ghost. V1.1 once WP + Ghost are solid. |
| **Slack MCP** | Internal comms / alerts | Anthropic Marketing plugin ships this | Low-medium | Helpful for team; solo founders don't need it. |

### Dead-ends (investigated, rejected or deferred indefinitely)

- **Substack MCP** — no write API from Substack. Community scrapers exist but are fragile. If you're on Substack and want automation, migrate to Beehiiv or Ghost. Skip.
- **Folk / Attio / Close MCP** — did not find maintained community MCPs for these CRMs. HubSpot covers the beachhead.
- **ProductHunt / HackerNews MCP** — launch-day tooling. Not a continuous-cadence activity; manual on launch day is correct.
- **TikTok direct MCP** — Postiz covers publishing; TikTok Content Posting API is viable but niche. Defer until a creator-type user asks.
- **QuickBooks** — confirmed out of scope (finance, not marketing).
- **Mailchimp / ConvertKit MCP** — viable alternatives to Resend but not found as maintained MCPs. Resend + Broadcasts is sufficient for v1. If drip automation is needed later, consider Customer.io (has strong API).

---

### Anthropic's official `Marketing` plugin (claude.com/plugins/marketing)

**Status:** Anthropic-Verified.

**Skills:** `/draft-content`, `/campaign-plan`, `/brand-review`, `/competitive-brief`, `/performance-report`, `/seo-audit`, `/email-sequence`.

**MCP deps:** Slack, Canva, Figma, HubSpot, Amplitude, Ahrefs, Klaviyo.

**Overlap analysis.**

The official plugin is aimed at **marketing teams inside larger orgs** (note: Slack, Amplitude, Ahrefs, Klaviyo all imply paid enterprise tiers). Our audience is solo founders.

- **Overlap:** `/seo-audit` and `/email-sequence` superficially. But their `/seo-audit` is LLM-driven content review, not tool-backed (no GSC/GA data). Different product.
- **No overlap:** strategy interview, daily operating rhythm, activity roster, channel-specific infrastructure setup, Reddit, Postiz, BillionMail/Ghost, Stripe read-for-marketing.

**Position:** don't compete on naming (avoid `/draft-content` or `/campaign-plan`), focus on the infrastructure + rhythm that the Anthropic plugin explicitly doesn't touch.

---

## Synthesis

### MCP-first rule (load-bearing)

The skill prefers MCP-backed recipes because:
1. Cross-client portability — Claude Desktop, Cursor, claude.ai, and Claude Code all work
2. Typed tools are better LLM affordance than shell commands
3. Secrets centralize in one config surface instead of scattering through Bash invocations

**Direct API is a documented fallback** when no maintained MCP exists. Recipes in that state carry a ⚠️ flag and an explicit "Claude Code only — uses Bash" note. Those are V2 targets for either a community MCP we adopt or a thin wrapper we write ourselves.

### Final v1 recipe set (16 recipes)

| Recipe | MCP status | V1? | Notes |
|---|---|---|---|
| wix | **Official native Claude connector** | ✅ | Zero setup, cleanest recipe |
| postiz | Bundled MCP in repo | ✅ | Hub for social publishing |
| ghost | `MFYDev/ghost-mcp` (npm: `@fanyangmeng/ghost-mcp`) | ✅ | Active |
| reddit | `karanb192/reddit-mcp-buddy` | ✅ | Active, 3-tier auth |
| stripe | **Official `stripe/agent-toolkit` MCP** | ✅ | Read-only restricted key |
| claude-seo | Plugin bundling DataForSEO + Firecrawl + nanobanana MCPs | ✅ | Covers GSC/GA4 via sub-skill |
| hubspot | Community MCP + Private App token | ✅ | Token is the credential |
| facebook-ads | `brijr/meta-mcp` or `pipeboard-co/meta-ads-mcp` | ✅ | Upgraded since Jan 2026 from ⚠️ to MCP |
| facebook-publish | **Via Postiz** (no direct MCP for Pages publishing) | ✅ | Postiz handles it |
| instagram | Via Postiz (publishing) + shares Meta app with facebook-ads | ✅ | Same Meta app for ads |
| linkedin | Via Postiz (publishing); direct is ⚠️ Bash-only fallback | ✅ | Postiz-only for v1 |
| twitter-x | Via Postiz (publishing); direct is ⚠️ Bash + $200/mo | ✅ | Postiz-only unless budget |
| youtube | Data API direct ⚠️ Bash-fallback; video-use is local tool | ✅ | No good YouTube MCP yet — V2 target to write one |
| gsc | No dedicated MCP; claude-seo's `seo-google` wraps; ⚠️ custom wrapper otherwise | ✅ | Covered by claude-seo |
| ga4 | Same as GSC | ✅ | Covered by claude-seo |
| wordpress | **`WordPress/mcp-adapter` (server) + `@automattic/mcp-wordpress-remote` (client)** | ✅ | Upgraded — official Automattic + WordPress.org stack |
| resend | ⚠️ Bash + REST; **NOT writing our own MCP** (user decision) | ✅ | Simple enough that direct is fine in Claude Code |

**16 recipes.** Wix added, Facebook split into facebook-ads (MCP) and facebook-publish (Postiz).

### ⚠️-flagged recipes (Claude Code only until MCP exists)

- youtube (Data API direct)
- linkedin (direct path)
- twitter-x (direct path)
- resend (user decided not to write our own)
- gsc / ga4 (if not using claude-seo)

These work today in Claude Code via Bash + curl, but Claude Desktop users are blocked. WordPress was here in the earlier draft; **upgraded to MCP-first** with the WordPress/mcp-adapter + Automattic/mcp-wordpress-remote stack. No more WP gap.

**No V2 MCP-writing commitments at this time.** Resend stays direct (user call).

### Companion install (separate concern — not a recipe)

`coreyhaines31/marketingskills` is a plugin of playbook skills, not infrastructure. Install-managed by `/market-library`, not `/market-stack`. See below.

---

## The fourth skill — `/market-library` (provisional name)

**Concept (from this session's conversation).** Skills ≠ infrastructure. Playbook skills (marketingskills, Anthropic Marketing, future community plugins) are the *thinking layer*. They belong in a separate, curated inventory — distinct from the MCP/credential/deploy layer that `/market-stack` owns.

**Scope.** Discover, install, and curate Claude Code plugins that ship marketing playbook skills. Recommend from a short opinionated list; let the user opt in per-plugin. Maintain a record of which playbooks are active for the current project. Integrates with `/daily-plan` — activities can reference playbook skills from installed plugins.

**V1 curated plugin list (opinionated):**

| Plugin | Author | What it is | Default? |
|---|---|---|---|
| marketingskills | coreyhaines31 | 40 marketing playbook skills, zero infra | **Yes** (recommended at first run) |
| claude-seo | AgriciDaniel | 20 SEO skills + DataForSEO/Firecrawl/banana MCPs | Suggested if strategy touches SEO |
| Anthropic Marketing | Anthropic | Content creation / brand voice / campaign planning | Suggested for team users (needs Slack/Amplitude/Ahrefs/Klaviyo) |
| digital-marketing-pro | indranilbanerjee | 115 commands, 67 MCPs, enterprise-scale | Mentioned with caveats; probably over-scale for solo |

**Why separate from `/market-stack`:**
- Different action: installing a plugin is not wiring up a credential.
- Different taxonomy: plugins curate skills; stack curates integrations.
- Different cadence: infrastructure is set up once, then audited periodically; playbook libraries are browsed, selected, and pruned more often.
- Different cognitive concern: "what do I want to THINK through" vs "what APIs are configured."

**User-facing modes (provisional):**

- `/market-library` — list recommended plugins, show installed vs available, let user pick
- `/market-library install <plugin>` — install a specific curated plugin (calls `/plugin install ...` under the hood)
- `/market-library audit` — check which installed playbook skills haven't been referenced in `marketing/activities.md` or `marketing/daily/*.md` — suggest pruning
- `/market-library suggest` — based on current strategy (channels, loops, personas), suggest playbooks from installed plugins to add to the activity roster

**Integration with `/daily-plan`:** activities.md gains an optional Playbook column:

| Activity | Skill | Playbook | Infrastructure | ... |
|---|---|---|---|---|
| Draft cold email | marketing-skills:/cold-email | — | recipe: resend | ... |
| Weekly CRO audit | marketing-skills:/page-cro | — | recipe: claude-seo, ga4 | ... |
| Scan Reddit | /scan-reddit (custom) | — | recipe: reddit | ... |

Skills the user scaffolds themselves still work; installed playbooks from plugins are just another source.

---

### Install order across all four skills (from cold-start)

1. `/marketing-strategy` — builds `marketing/01–08_*.md` from an 8-step interview.
2. `/market-library` — installs curated playbook plugins (marketingskills, claude-seo if SEO is inner-ring). User sees the catalogue and opts in.
3. `/market-stack` — reads strategy, figures out which infrastructure recipes are needed, guides install in credential-sharing-aware order (Wix OR Ghost OR WordPress; Meta app once; GCP SA once; Postiz early for social hub). Writes `marketing/infrastructure.md`.
4. `/daily-plan` — first run bootstraps `marketing/activities.md` from strategy + installed playbooks + installed recipes. Daily mode picks activities whose infrastructure and playbooks are both `ready`.

### The three-layer split

- **Strategy layer** (`/marketing-strategy`) — WHAT to do over 90 days.
- **Library layer** (`/market-library`) — HOW to think about each kind of work (playbooks).
- **Stack layer** (`/market-stack`) — WHAT'S WIRED UP (infrastructure).
- **Execution layer** (`/daily-plan`) — WHAT to do TODAY, drawing from all three above.

This is a cleaner mental model than collapsing library and stack into one skill.

### Install order (credential-sharing aware)

The recipes are not independent — credentials and infrastructure share. Opinionated order:

1. **Foundation:** Google Cloud project + service account (covers GSC, GA4, YouTube Data API) → claude-seo install → `.env` + `~/.config/claude-seo/google-api.json` credentials file
2. **Content publishing layer:** pick ONE of [WordPress, Ghost] based on strategy. Set up Admin API credentials.
3. **Social publishing hub:** Postiz deploy (Railway/docker-compose). Once running, it handles FB + IG + LinkedIn + Twitter + YouTube publishing via one OAuth per channel *inside Postiz*.
4. **Meta app:** ONE Meta developer app → covers FB + IG direct API access. Do App Review once. Skip if only publishing (Postiz covers it).
5. **LinkedIn direct:** skip for v1 unless you need Newsletters (invite-only anyway).
6. **Twitter/X direct:** only if $200/mo Basic tier is justified. Otherwise Postiz-only.
7. **CRM + revenue:** HubSpot Private App + Stripe Restricted Key. Identity-resolution metadata at Checkout creation is critical — set `metadata[hubspot_contact_id]` and mirror `stripe_customer_id` in HubSpot on day 1.
8. **Email:** Resend (already in use) or Ghost-native if chose Ghost as CMS.
9. **Reddit:** reddit-mcp-buddy with tier-3 creds on a dedicated bot account.
10. **Companion:** install `marketingskills` via `/plugin install marketing-skills` — referenced by daily-plan activities.

### Credential-sharing map

| Credential | Covers |
|---|---|
| GCP service account JSON + API key | GSC, GA4, YouTube Data API, PageSpeed, CrUX, Indexing (via claude-seo `seo-google`) |
| Meta developer app (App ID + App Secret + long-lived Page token) | Facebook Page + Instagram Business via Graph API |
| Postiz API key + Postiz's internal OAuths | FB publish, IG publish, LinkedIn publish, Twitter publish, YouTube publish, Reddit publish, TikTok publish, Bluesky publish, Mastodon, Threads |
| Reddit app credentials | reddit-mcp-buddy (read-only) |
| Ghost Admin API key | Ghost posts + newsletters + members + tiers (publish + email all from one key) |
| HubSpot Private App token | HubSpot CRM read + write |
| Stripe Restricted Key | Stripe read for revenue intelligence |
| Resend API key | Email broadcast + transactional |
| WordPress Application Password | WordPress REST API |

### Integration with `/daily-plan`

The `marketing/activities.md` roster currently tracks: Skill, Channel, Loop, Cadence, Time, Status, Last used.

Add an **Infrastructure** column that references the recipe(s) an activity depends on:

| Activity | Skill | Infrastructure | Status | Loop | ... |
|---|---|---|---|---|---|
| Scan Reddit | `/scan-reddit` | recipe: reddit | active | Acquisition |
| Publish weekly post | `/draft-content` (marketingskills) → `/ghost publish` | recipes: ghost | active | Acquisition |
| Weekly CRO audit | `/page-cro` (marketingskills) → `/seo-page` | recipes: claude-seo, ga4 | active | Activation |
| Subscription review | custom | recipes: stripe, hubspot | active | Monetization |

`/daily-plan` reads infrastructure status at pick time:
- ✅ All recipes in `ready` state → activity runnable
- ⚠ Recipe `setup-pending` or token expired → activity blocked, surfaces "run `/market-stack fix <recipe>`"
- ❌ Recipe not installed → activity blocked, surfaces "run `/market-stack install <recipe>`"

This turns infrastructure health into a first-class input for daily execution.

### V2 backlog

- BillionMail (when API lands)
- Beehiiv (official paid MCP, early access)
- Discord (when community-building is inner-ring)
- Notion CMS (v1.1 addition)
- Shopify (for DTC/ecom users)
- Adspirer (when ad budget exists)
- Customer.io (when drip automation needed)

### Proposed directory structure for `/market-stack`

```
plugins/market-my-spec/skills/market-stack/
├── SKILL.md                    ← orient, modes, recipe inventory
├── steps/
│   ├── inventory.md            ← what's installed vs what strategy needs
│   ├── install_recipe.md       ← guided setup per recipe (reads recipes/<name>/RECIPE.md)
│   ├── audit_health.md         ← credential freshness, MCP connectivity checks
│   ├── fix_recipe.md           ← re-auth, re-install, diagnostics
│   └── blueprint.md            ← writes marketing/infrastructure.md
└── recipes/
    ├── reddit/RECIPE.md
    ├── postiz/RECIPE.md
    ├── facebook/RECIPE.md
    ├── instagram/RECIPE.md
    ├── linkedin/RECIPE.md
    ├── twitter-x/RECIPE.md
    ├── youtube/RECIPE.md
    ├── claude-seo/RECIPE.md
    ├── gsc/RECIPE.md
    ├── ga4/RECIPE.md
    ├── wordpress/RECIPE.md
    ├── ghost/RECIPE.md
    ├── hubspot/RECIPE.md
    ├── stripe/RECIPE.md
    └── resend/RECIPE.md
```

### User-facing modes (provisional)

- `/market-stack` (no args) — inventory + recommendations vs current strategy
- `/market-stack install <recipe>` — guided install of one recipe
- `/market-stack install-for-channel <channel>` — install the complete toolchain for a channel (e.g., "reddit" installs reddit-mcp-buddy + links to reddit-linking-playbook)
- `/market-stack audit` — health check all installed recipes (credentials still valid, MCPs responding)
- `/market-stack fix <recipe>` — diagnostic + re-auth
- `/market-stack blueprint` — regenerate `marketing/infrastructure.md`

### Open design questions for next session

1. **Scope of `/market-stack install-for-channel`.** Does "install reddit" include installing the reddit-mcp-buddy MCP PLUS setting up a personas file + UTM convention + touchpoint log format? Or just the MCP? Leans toward: MCP + minimal conventions file, rest is downstream.
2. **Health check granularity.** Is "credentials still valid" a blocking check at daily-plan time, or periodic (weekly)? Leans: periodic at weekly review, lightweight in daily mode (check only the activities being run today).
3. **marketingskills companion install.** Prompt the user at first run of `/market-stack`, or silently recommend in the blueprint? Leans: explicit prompt once, record preference.
4. **Ghost vs WordPress mutual exclusion.** Most users pick one. Should `/market-stack install ghost` warn if WordPress is already installed? Leans: yes — prompt for "migrating or running both?" rather than silently adding.
5. **Postiz deploy.** Do we attempt to guide Railway/docker deploy, or cap at "deploy it yourself, come back with URL+key"? Leans: cap. Deployment is out of scope for the skill.

---

## Summary for the next session

Research complete. 15 recipes drafted, one major companion plugin (marketingskills) identified as install-not-compete. Clear install order with credential-sharing map. Integration path with `/daily-plan` defined (infrastructure column in activities.md, ready/blocked status gates daily picks). Ready to design the `/market-stack` skill: confirm open design questions, then build SKILL.md + step files + per-recipe RECIPE.md files.
