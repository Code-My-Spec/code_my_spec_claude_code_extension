---
name: hubspot
channel: crm
loop_fit: [acquisition, activation, retention]
primary_mcp_status: community-active
requires_server_install: false
requires_deploy: false
---

# HubSpot

## What it is
HubSpot CRM read-first access (contacts, deals, engagements) with write-back for touchpoint logging. Uses a Private App access token — scoped, revocable, supported on free tier.

## Unlocks
- Activities: "Monday funnel review — new contacts, stage changes, stalled deals," "log this newsletter send as engagement," "segment by lifecycle stage for next campaign," "identify cold MQLs for re-engagement"

## Prerequisites
- A HubSpot account (free tier works for most)
- Admin access to create Private Apps

## Install steps
1. **Create HubSpot Private App:**
   - HubSpot → Settings (gear) → Integrations → Private Apps → Create private app
   - Name: `claude-marketing-stack`
   - Scopes: `crm.objects.contacts.read`, `crm.objects.contacts.write`, `crm.objects.deals.read`, `crm.objects.deals.write`, `crm.objects.companies.read`, `crm.schemas.contacts.read`, `crm.lists.read`, `sales-email-read`, `tickets.read` (if using Tickets)
   - Click Create → Show token → copy the `pat-na1-...` Bearer token
2. **Find your Portal ID:** top-right of HubSpot UI (numeric).
3. **Register the MCP:** pick the active community HubSpot MCP — check https://github.com/search?q=mcp+hubspot&type=repositories for current maintenance. At time of writing, suggested:
   ```bash
   claude mcp add --transport stdio hubspot -s user -- npx -y <hubspot-mcp-package>
   ```
   (User may need to verify the specific package; this ecosystem moves.)
4. Add env vars to `.env`.

## .env requirements
```
HUBSPOT_PRIVATE_APP_TOKEN=   # pat-na1-... Bearer
HUBSPOT_PORTAL_ID=           # numeric hub ID, top-right of UI
```

## Validation
`curl -H "Authorization: Bearer $HUBSPOT_PRIVATE_APP_TOKEN" "https://api.hubapi.com/crm/v3/objects/contacts?limit=1"` → `{"results":[{...}]}` with ≥1 contact. Or via the MCP: "Using HubSpot, list 3 recent contacts."

## Conventions to seed
Write `marketing/conventions/crm.md`:

```markdown
# HubSpot conventions

## Lifecycle stages
- Subscriber → Lead → MQL → SQL → Opportunity → Customer → Evangelist
- `lifecyclestage` moves forward-only by default; to demote, set to empty first then move.
- Custom stages added via Settings → Properties → Contact Properties.

## Touchpoint logging
- Every marketing activity that reaches a known contact → log an Engagement.
- Engagement types: email (newsletter send), note (ad-hoc), task (follow-up).
- Template: `{activity_name} — {date} — {outcome}`.

## Segmentation
- Use active lists for dynamic segments, static lists for campaign-specific cohorts.
- List name format: `{purpose}-{date-or-cycle}`, e.g., `mql-warm-2026-Q2`.

## Identity resolution with Stripe (if using both)
- Custom contact property: `stripe_customer_id`.
- Set at Checkout handoff. Enables "which contacts converted to paid?" queries.

## Free-tier limits
- 100 req / 10 sec, 250k req/day per portal. Paginate with `limit=100` + `after` cursor.
- Search API stricter: 5 req/sec, max 10k results per query.
- No marketing-email send API on free tier — read/segment only.
```

## Gotchas
- Free + Starter: 100 req / 10 sec.
- `lifecyclestage` forward-only.
- Engagements v1 is legacy — prefer v3 `/crm/v3/objects/emails`.
- Free tier no marketing-email send.
- Private App tokens don't expire automatically but can be revoked.

## Links
- API docs: https://developers.hubspot.com/docs/api/overview
- Private Apps: https://developers.hubspot.com/docs/api/private-apps
- Rate limits: https://developers.hubspot.com/docs/api/usage-details
