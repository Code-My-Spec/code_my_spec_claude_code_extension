---
name: linkedin
channel: social
loop_fit: [acquisition, activation]
primary_mcp_status: via-postiz
requires_server_install: false
requires_deploy: false
---

# LinkedIn

## What it is
LinkedIn personal profile + Company Page posting via **Postiz (primary path)**. Direct LinkedIn Marketing Developer Platform (MDP) API access is a ⚠️ Claude Code-only fallback — and MDP itself is gatekept (1-3 week partner application, sometimes rejected for solo devs).

## Unlocks
- Activities: "daily LinkedIn post," "Company Page digest," "comment-engagement sweep"

## Prerequisites
- **Postiz path:** `postiz` recipe installed + LinkedIn connected in Postiz UI
- **Direct path:** LinkedIn Developer app with Marketing Developer Platform approval + Company Page Super Admin access (if posting to Company Page)

## Install steps

### Via Postiz (strongly recommended)

1. `postiz` recipe ready.
2. Postiz → Channels → Add LinkedIn → OAuth to personal account.
3. For Company Page: you must be **Super Admin** of the Page. Postiz re-prompts for page scope.
4. Done.

### Direct LinkedIn API (⚠️ Claude Code only, only if Postiz not used)

1. linkedin.com/developers/apps → Create app → associate to a Company Page.
2. Products → request **Share on LinkedIn** + **Marketing Developer Platform**. MDP is the slow one (1-3 weeks, sometimes rejected).
3. Scopes: `w_member_social`, `r_liteprofile`, `r_emailaddress`, `w_organization_social`.
4. OAuth 2.0 flow for access token.

## .env requirements

### Postiz path: none.

### Direct path:
```
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=
LINKEDIN_ACCESS_TOKEN=      # 60-day expiry. refresh_token 1-year capped.
LINKEDIN_ORG_URN=           # urn:li:organization:<id>, from /v2/organizationAcls?q=roleAssignee
```

## Validation
Postiz: "List my LinkedIn channels through Postiz."
Direct: `curl -H "Authorization: Bearer $LINKEDIN_ACCESS_TOKEN" https://api.linkedin.com/v2/userinfo`

## Conventions to seed
Append to `marketing/conventions/social.md`:

```markdown
## LinkedIn specifics

## Post cadence
- 1 post/day max; tuesday-thursday peak.
- Burst posting (5+/day) gets flagged.

## Post format rotation
1. Story / personal frame
2. Contrarian take
3. Framework / how-to
4. Case study / customer story
- Rotate weekly to avoid template fatigue.

## Engagement window
- Respond to comments within first 60 min of posting — algo rewards.
- DM responders within 24h — they're the highest-intent audience.

## Content that works on LinkedIn (2026)
- Build-in-public progress, specifics (numbers, named people)
- Reflections from real client work
- Opinions with skin in the game

## What doesn't work
- Motivational quotes
- "Hot takes" without substance
- Engagement-bait polls
```

## Gotchas
- **Tokens expire every 60 days.** `refresh_token` 1-year capped. Re-auth yearly unavoidable.
- Company Page posting requires Super Admin (not just connected).
- **Newsletters API is invite-only** as of 2026 — don't plan on it for v1.
- Video > 200MB needs multi-part upload.
- Bursty posting flagged. < 5 posts/day/account.
- MDP rejection is common for solo devs — Postiz is the escape hatch.

## Links
- Via Postiz: https://docs.postiz.com
- LinkedIn developer portal: https://www.linkedin.com/developers/apps
- Marketing docs: https://learn.microsoft.com/en-us/linkedin/marketing/
