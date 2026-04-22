---
name: instagram
channel: social
loop_fit: [acquisition, retention]
primary_mcp_status: via-postiz
requires_server_install: false
requires_deploy: false
---

# Instagram

## What it is
Instagram Business/Creator publishing + insights. **Routes through the `postiz` recipe for publishing.** Shares the Meta developer app with `facebook-ads` and `facebook-publish`.

Direct Graph API access available for insights / hashtag search — ⚠️ Claude Code only.

## Unlocks
- Activities: "daily IG post or Reel," "weekly insights pull," "comment triage," "hashtag research"

## Prerequisites
- Instagram Business or Creator account (NOT personal — hard requirement)
- Instagram linked to a Facebook Page (non-negotiable Meta requirement)
- `postiz` recipe installed (publishing path) OR Meta developer app (direct path)

## Install steps

### Via Postiz (primary path)

1. Confirm `postiz` is ready.
2. Inside Instagram app: Profile → Settings → Account type → switch to **Business** or **Creator** if personal.
3. Facebook Page → Settings → Linked Accounts → Instagram → connect.
4. Postiz UI → Channels → Add Instagram → OAuth (reuses Meta app via Postiz).

### Direct Graph API (for insights / hashtag search — ⚠️ Claude Code only)

1. Meta developer app created (share with facebook-ads / facebook-publish).
2. Add product: **Instagram Graph API**.
3. App Review: `instagram_basic`, `instagram_content_publish`, `instagram_manage_insights`, `instagram_manage_comments`.
4. Find IG Business Account ID: `GET /{page-id}?fields=instagram_business_account` with the Page token.

## .env requirements

### Postiz path:
None — Postiz holds the token.

### Direct path (add to `.env`):
```
IG_BUSINESS_ACCOUNT_ID=     # 17-digit, from /{page-id}?fields=instagram_business_account
# Reuses META_APP_ID, META_APP_SECRET, FB_PAGE_ACCESS_TOKEN from facebook-ads recipe
```

## Validation
Postiz: "Using Postiz, list my Instagram channels."
Direct: `curl "https://graph.facebook.com/v19.0/$IG_BUSINESS_ACCOUNT_ID?fields=username,followers_count&access_token=$FB_PAGE_ACCESS_TOKEN"`

## Conventions to seed
Append to `marketing/conventions/social.md`:

```markdown
## Instagram specifics

## Post format priority
- Reels > carousels > single images > Stories (for reach)
- Stories > feed (for existing-audience engagement)
- First 3 seconds of Reels = hook or loss

## Hashtag discipline
- 5-10 relevant tags per post
- Mix: 3 niche + 3 medium + 2 broad
- Don't repeat the same 10 tags on every post — flags algo

## Story cadence
- Daily when active, never with campaign gaps > 3 days
- Polls + questions sticker = 2-5x reach bump

## Link handling
- No clickable links in feed captions
- Link-in-bio tool (Linktree, or a Ghost landing page) is the router

## Hashtag search rate-limit
- 30 queries / 7 days / user — budget carefully
```

## Gotchas
- **Personal accounts cannot use Graph API.** Business or Creator only.
- **IG must be linked to a Facebook Page.** Three conversions before any API call.
- Reels upload is async two-step (create container → publish). 30-60s poll loop.
- Stories publishing via API is **partner-gated** — assume no.
- 25 API-published posts per IG account per 24h.
- No DM send from API unless Instagram Messaging partner.
- Hashtag search: 30 queries / 7 days / user.

## Links
- Via Postiz: https://docs.postiz.com
- Instagram Graph API: https://developers.facebook.com/docs/instagram-api
- Content publishing: https://developers.facebook.com/docs/instagram-api/guides/content-publishing
