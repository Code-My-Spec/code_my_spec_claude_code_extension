---
name: facebook-ads
channel: social
loop_fit: [acquisition]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
---

# Facebook Ads (Meta Marketing API)

## What it is
Meta Marketing API (Facebook + Instagram ads) via a maintained MCP — either `brijr/meta-mcp` or `pipeboard-co/meta-ads-mcp`. Both active as of 2026. Pipeboard is a badged Meta Business Partner.

**This recipe is for paid ads only.** Organic Facebook/Instagram publishing routes through the `postiz` recipe, not here.

## Unlocks
- Activities: "weekly ad performance review (CTR, CPM, CPA)," "pause underperforming ad sets," "launch test creative," "audience insights pull for segment design"

## Prerequisites
- Meta Business Manager account
- **Business Verification completed** — required for Marketing API
- An active ad account (with payment method)
- Admin access to the Meta developer app (can be shared with `instagram` and `facebook-publish` recipes)

## Install steps
1. **Create / reuse the Meta developer app:**
   - developers.facebook.com/apps → Create App → **Business** type
   - Add product: **Marketing API**
   - Settings → Basic → note App ID + App Secret
2. **Business Verification:**
   - Meta Business Manager → Business Settings → Business Info → complete verification if not already done. Can take days — plan for it.
3. **Generate Marketing API access token:**
   - Graph API Explorer → select your app → Get User Access Token → grant `ads_management`, `ads_read`, `business_management`, `pages_read_engagement`
   - Convert to long-lived token: `GET /oauth/access_token?grant_type=fb_exchange_token&client_id=<APP_ID>&client_secret=<APP_SECRET>&fb_exchange_token=<SHORT_TOKEN>`
   - Or: create a System User in Business Manager and generate a System User token (doesn't expire) — recommended for production.
4. **Find your Ad Account ID:** Business Manager → Business Settings → Ad Accounts → numeric `act_xxxxxxxxx`.
5. **Register the MCP (choose one):**
   ```bash
   # Option A — brijr/meta-mcp (general Marketing API coverage)
   claude mcp add --transport stdio meta-mcp -s user -- npx -y meta-mcp

   # Option B — pipeboard-co/meta-ads-mcp (Meta Business Partner badged, streamable HTTP)
   # See the repo for install transport options
   ```
6. Add env vars to `.env`.

## .env requirements
```
META_APP_ID=                  # developers.facebook.com → App Dashboard
META_APP_SECRET=              # Settings → Basic → App Secret
META_AD_ACCOUNT_ID=           # act_xxxxxxxxx from Business Settings
META_ACCESS_TOKEN=            # System User token (preferred) or long-lived user token (60d refresh)
```

## Validation
"Using meta-mcp, list my ad campaigns." Expect JSON with campaign IDs, names, status.

## Conventions to seed
Append to `marketing/conventions/social.md` (created by `postiz` recipe):

```markdown
## Meta Ads (if running paid)

## Weekly review metrics
- Spend, CTR, CPM, CPA per campaign
- Frequency (>3 = creative fatigue)
- ROAS where revenue attribution is set

## Creative test structure
- 3 hooks × 2 body copy × 2 CTAs = 12 variants per campaign
- Kill ad sets at 2× target CPA after $100 spent

## Audience discipline
- Retargeting: 30-day purchaser exclusion baseline
- Lookalike: 1% for cold, 5-10% for mid-funnel retargeting
- Interest stacking: start narrow (1-2 interests), expand only on proof

## Budget caps
- No ad set starts above $20/day without historical CPA benchmark
- Campaign budget optimization (CBO) for stable performers
```

## Gotchas
- **Business Verification is the hard gate.** Can take days. Start early.
- Ad Accounts can be disabled without warning — monitor and keep payment method active.
- Marketing API has tier-based rate limits based on ad spend — early-stage accounts are heavily throttled.
- Instagram ads use the same app but require Instagram Business account linked to a Facebook Page.
- `ads_management` scope requires App Review unless you're staying inside your developer app's admin list.

## Links
- Option A source: https://github.com/brijr/meta-mcp
- Option B source: https://github.com/pipeboard-co/meta-ads-mcp
- Meta developers portal: https://developers.facebook.com/apps
- Marketing API docs: https://developers.facebook.com/docs/marketing-apis
