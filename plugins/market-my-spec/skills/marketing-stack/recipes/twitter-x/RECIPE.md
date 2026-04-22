---
name: twitter-x
channel: social
loop_fit: [acquisition]
primary_mcp_status: via-postiz-or-paid
requires_server_install: false
requires_deploy: false
---

# Twitter / X

## What it is
X / Twitter posting via **Postiz (primary path)** or X API v2 direct (⚠️ Basic tier $200/mo for write + read). No good free MCP post-2023 API crackdown.

**If $200/mo isn't justified:** skip X automation entirely. Post manually, or publish-only via Postiz without the read/search capability.

## Unlocks
- Activities: "daily tweet batch," "reply-guy engagement window," "thread publish," "keyword listening" (only with direct Basic-tier access)

## Prerequisites
- **Postiz path:** `postiz` recipe installed + X connected in Postiz
- **Direct path:** X developer account + Basic tier subscription ($200/mo) + OAuth 2.0 user token

## Install steps

### Via Postiz (publishing only, recommended for solo founders)

1. `postiz` recipe ready.
2. Postiz → Channels → Add X → OAuth.
3. Done. Publishing works. Read/search not covered through Postiz.

### Direct X API (only if $200/mo is in budget)

1. developer.x.com/en/portal/dashboard → sign in with posting account.
2. Create Project + App. New accounts sometimes get 48h review.
3. Subscribe to **Basic ($200/mo)** — Free tier is crippled (1500 posts/mo write-only, no read).
4. Enable OAuth 2.0 with PKCE; set redirect URI.
5. User auth settings: **Read and write** (+ DMs if needed).
6. Generate API Key, API Secret, Bearer Token, plus OAuth2 user access token.

## .env requirements

### Postiz path: none.

### Direct path:
```
X_API_KEY=                  # developer.x.com → app → Keys and tokens → API Key
X_API_SECRET=               # same screen
X_BEARER_TOKEN=             # app-only auth (read-only)
X_ACCESS_TOKEN=             # user-context OAuth 2.0
X_ACCESS_TOKEN_SECRET=      # OAuth 1.0a, some v1.1 endpoints still need it
```

## Validation
Postiz: "List my X channels through Postiz."
Direct: `curl -H "Authorization: Bearer $X_BEARER_TOKEN" "https://api.x.com/2/users/me"`

## Conventions to seed
Append to `marketing/conventions/social.md`:

```markdown
## Twitter / X specifics

## Daily cadence
- 1-3 tweets/day max (Basic tier: 100/24h per user hard cap)
- Engage 10x for every 1 post

## Thread discipline
- No atomic thread endpoint — sequential posts with `in_reply_to_tweet_id`
- Hook tweet is the whole job — if it dies, the thread dies

## Engagement windows
- Reply-guy on target accounts M-F, 1-2h windows
- Target: senior voices in niche, not generalists

## Automation rule
- Anti-automation policies enforced — vary templates, don't post identical text
- If flagged, account throttled without warning

## Listening
- Only with Basic+ tier ($200/mo); Free tier has no read access

## Scheduling
- Through Postiz — never direct cron; appearance of automation penalized
```

## Gotchas
- **Basic tier: 100 posts / 24h per user, 1667 reads / 15 min.** Pro is 10× but $5000/mo.
- Media upload via `upload.twitter.com/1.1/media/upload.json` (v1.1 hybrid API).
- Threads = sequential posts. No single-call thread creation.
- Anti-automation rules enforced; vary templates.
- Tokens don't expire but can be revoked (account suspension or policy violation).
- X policy/pricing shifted 3+ times since 2023. Design for API swap.
- **Scrapers are bannable.** Don't.

## Links
- Via Postiz: https://docs.postiz.com
- X developer portal: https://developer.x.com/en/portal/dashboard
- X API docs: https://docs.x.com/x-api
- Pricing: https://developer.x.com/en/products/x-api
