---
name: facebook-publish
channel: social
loop_fit: [acquisition, retention]
primary_mcp_status: via-postiz
requires_server_install: false
requires_deploy: false
---

# Facebook — organic publishing

## What it is
Facebook Page organic publishing. **Routes through the `postiz` recipe — no separate install.**

If Postiz isn't an option, there's a ⚠️ direct-API Bash fallback (Claude Code only).

## Unlocks
- Activities: "daily FB page post," "weekly FB insights pull," "cross-channel announcement"

## Prerequisites
- `postiz` recipe installed and in `ready` state
- Facebook Page connected inside Postiz via OAuth

## Install steps
1. Confirm `postiz` is ready. If not: "Install the `postiz` recipe first with `/marketing-stack install postiz`."
2. In Postiz UI → Channels → Add Facebook Page → OAuth → select the Page(s) you manage.
3. That's it. Posting via Postiz MCP now targets the connected Page(s).

## .env requirements
None. Postiz holds the token.

## Validation
"Using Postiz, publish a test draft to Facebook Page (don't schedule)." Check it appears as draft in Postiz UI.

## Conventions to seed
Append to `marketing/conventions/social.md` (from `postiz` recipe):

```markdown
## Facebook Page specifics

## Post types
- Link posts: include preview image + 1-2 sentence hook above the link.
- Photo posts: native images perform better than external.
- Video: native upload > link to YouTube.

## Audience engagement
- Reply to every comment within 24h.
- Pin important posts for visibility in new-visitor feed.

## Timing
- 9-10am and 3-4pm local time hit highest organic reach (broad rule).
- Avoid weekends for B2B; weekends work for B2C.

## Weekly insights review
- Reach, engaged users, page followers delta
- Top 3 posts by engagement — what worked?
```

## Direct-API fallback (⚠️ Claude Code only — only if Postiz isn't used)

Skip this section if using Postiz.

If you must go direct:
1. Meta developer app (share with `facebook-ads` / `instagram`)
2. Request App Review for `pages_show_list`, `pages_read_engagement`, `pages_manage_posts` (5-15 business days)
3. Generate long-lived Page Access Token via Graph API Explorer
4. Bash calls: `curl -X POST "https://graph.facebook.com/v19.0/$FB_PAGE_ID/feed" -d "message=hello&access_token=$FB_PAGE_ACCESS_TOKEN"`

`.env` (fallback only):
```
FB_PAGE_ID=
FB_PAGE_ACCESS_TOKEN=      # 60-day expiry; convert to System User token for no-refresh
```

Skill `/seo-*` or `/draft-content` from marketingskills can produce draft text; a Bash call publishes. Works in Claude Code, not in Claude Desktop.

## Gotchas
- Postiz path: if the Facebook OAuth inside Postiz breaks, re-auth in Postiz UI; that's the whole fix.
- Direct-API path: App Review gate + token expiry are real. Plan for 60-day re-auth.
- No API for Groups (not Pages) — solo founders sometimes forget this.

## Links
- Postiz docs (Facebook setup): https://docs.postiz.com
- Direct Graph API: https://developers.facebook.com/docs/pages-api
