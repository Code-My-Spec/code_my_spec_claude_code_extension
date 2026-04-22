---
name: ga4
channel: analytics
loop_fit: [acquisition, activation, monetization]
primary_mcp_status: via-claude-seo
requires_server_install: false
requires_deploy: false
---

# Google Analytics 4 (GA4 Data API)

## What it is
GA4 report data: sessions, users, pageviews, engagement, conversions, revenue — filtered by channel group, date range, landing page, device, country, source/medium. Replaces the deprecated Universal Analytics Reporting API.

**If `claude-seo` is installed, GA4 is already covered via its `seo-google` sub-skill.** This recipe is redundant in that case.

## Unlocks
- Activities: "weekly Organic Search sessions by landing page," "conversion rate by channel group review," "top-10 pages audit with sessions + engagement metrics," "UTM campaign performance pull"

## Prerequisites
- Google Cloud project + service account (shared with `gsc`, `youtube`, `claude-seo`)
- Service account granted Viewer access to each GA4 property

## Install steps

### Primary path: via claude-seo

Installed and working if `claude-seo` is ready. Use `/seo google ga4` or `/seo google ga4-pages` sub-skills.

### Alternative: standalone thin MCP wrapper (⚠️ custom)

No canonical GA4 MCP as of April 2026. If standalone is needed, write a thin MCP over `google-analytics-data` (pypi) or `@google-analytics/data` (npm). The `runReport` method is the 90% call.

## API setup

1. GCP project: reuse GSC project.
2. Enable API: **Google Analytics Data API**.
3. Service account: reuse or create. Same pattern as `gsc`.
4. **Grant GA4 property access:**
   - analytics.google.com → Admin (gear, bottom left) → Property column → **Property Access Management** → `+` → paste service account `client_email` → **Viewer** (sufficient for `runReport`).
5. **Find the Property ID:** Admin → Property Details → numeric like `123456789`. API expects `properties/123456789`.

## Required OAuth scope
- `https://www.googleapis.com/auth/analytics.readonly`

## .env requirements
```
# Via claude-seo: no .env needed. Config at ~/.config/claude-seo/google-api.json handles it.

# Standalone wrapper:
GOOGLE_APPLICATION_CREDENTIALS=   # path to service account JSON
GA4_PROPERTY_ID=                  # properties/123456789
```

## Validation
Run the canonical first query — Organic Search sessions, last 28 days, by landing page:

```json
{
  "dimensions": [
    {"name": "landingPagePlusQueryString"},
    {"name": "sessionDefaultChannelGroup"}
  ],
  "metrics": [
    {"name": "sessions"},
    {"name": "engagedSessions"},
    {"name": "conversions"}
  ],
  "dateRanges": [{"startDate": "28daysAgo", "endDate": "today"}],
  "dimensionFilter": {
    "filter": {
      "fieldName": "sessionDefaultChannelGroup",
      "stringFilter": {"value": "Organic Search"}
    }
  }
}
```

Non-empty rows = working.

## Conventions to seed
Covered by `marketing/conventions/seo.md` (written by `claude-seo` recipe).

Additional GA4-specific conventions can be appended:

```markdown
## GA4 conventions (from ga4 recipe)

## Property hygiene
- Enable "Include Google signals" for demographic data.
- Set `sessionDefaultChannelGroup` filter discipline — "Organic Search" vs "(other)" means your channel groups aren't configured.

## Events & conversions
- Mark signup, checkout_complete, subscription_start as conversions.
- Don't mark pageviews as conversions — noise.

## Custom dimensions for attribution
- `utm_source_first_touch` (at user creation)
- `utm_campaign` stamped on key events

## Retention
- Default 14 months; extend to 14 months max for user-level analysis.
```

## Gotchas
- **Per-property grants required.** Same as GSC — service account with no property access = 403s.
- 10 concurrent requests per property.
- Per-project daily token budget (~25K tokens/day free tier; complex reports burn more).
- 429 errors on quota; use exponential backoff.
- `sessionDefaultChannelGroup` has specific categories; custom sources need explicit mapping.

## Links
- Via claude-seo: `/seo-google` skill.
- GA4 Data API: https://developers.google.com/analytics/devguides/reporting/data/v1
- Sample queries: https://developers.google.com/analytics/devguides/reporting/data/v1/basics
