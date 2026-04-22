---
name: youtube
channel: youtube
loop_fit: [acquisition]
primary_mcp_status: direct-api
requires_server_install: false
requires_deploy: false
---

# YouTube

## What it is
Two distinct integrations, different activities:

- **Publishing + own-channel analytics:** YouTube Data API v3 + YouTube Analytics API — ⚠️ Claude Code only (Bash + curl). Covered by `claude-seo`'s Google Cloud foundation if installed.
- **Content research / competitor intel / transcripts:** `browser-use/video-use` — Playwright-based agentic browser. Not an MCP. Requires local Chromium + an LLM API key.

No good YouTube MCP published as of April 2026. Direct Data API works; video-use runs separately for research.

## Unlocks
- Activities: "weekly long-form upload," "Shorts post," "comment triage," "competitor content research," "topic/thumbnail research"

## Prerequisites
- A YouTube channel with a linked Google account
- Access to the same Google Cloud project used by `claude-seo` (shares the service account + API key)
- For video-use: local Chromium, an LLM API key (Anthropic or OpenAI)

## Install steps

### Data API v3 (publishing + own-channel analytics)

1. GCP Console → APIs & Services → Library → enable **YouTube Data API v3** and **YouTube Analytics API** in the same project as claude-seo.
2. OAuth consent: External, add your email as test user (avoids verification gate for personal use).
3. Credentials → Create OAuth 2.0 Client ID → **Desktop app** type.
4. Run a local OAuth flow once (Google's `oauth2l` or a Python script) to obtain a refresh token.
5. Store refresh token in `.env`.

### video-use (research / competitor intel)

1. Python env available.
2. `pip install video-use` (or `uv add video-use`)
3. `playwright install chromium` — brings down Chromium for the agent loop.
4. Set an LLM API key in `.env` for video-use's internal agent.
5. Wrap as a local CLI script or a custom MCP if you want Claude-native tool access. No published MCP as of Apr 2026.

## .env requirements
```
YT_CLIENT_ID=               # from Credentials → OAuth 2.0 Client IDs
YT_CLIENT_SECRET=           # same
YT_REFRESH_TOKEN=           # one-time OAuth flow result; long-lived
YT_CHANNEL_ID=              # studio.youtube.com → Settings → Channel → Advanced. UC...

# For video-use:
ANTHROPIC_API_KEY=          # or OPENAI_API_KEY; video-use uses one of these internally
```

## Validation
Data API (public read): `curl "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=$YT_CHANNEL_ID&key=<API_KEY>"`
OAuth'd call (own channel): use the refresh token to obtain an access token, then `GET /youtube/v3/channels?mine=true&part=snippet,statistics`.
video-use: `python -c "from video_use import Agent; print(Agent().run('Summarize https://youtu.be/<short-video>'))"`

## Conventions to seed
Write `marketing/conventions/youtube.md`:

```markdown
# YouTube conventions

## Publishing discipline
- Unlisted first, public after self-review.
- Title + description: target keyword in first 60 chars of title; 200+ chars description with timestamps.
- Thumbnail: custom, not auto-generated.
- End screens + cards set before publish.

## Quota budget (Data API 10k units/day default)
- Upload = 1600 units → ~6 uploads/day cap without quota increase.
- Search = 100 units/query — don't burn on casual queries.
- Request quota increase (free, ~1 week) before real usage.

## Research via video-use (separate tool)
- Transcript extraction for competitor analysis
- "Watch this and tell me what's working" queries
- Runs local Chromium; costs LLM tokens per navigation
- Research only — never as a publishing path (YouTube detects automation)

## Analytics review
- Weekly: views, watch time, subscribers gained, avg view duration
- Monthly: top 5 videos — what's the pattern?

## Uploading
- New OAuth apps are quota-locked to unlisted uploads until Google audits.
- Submit for audit before relying on public uploads.
```

## Gotchas
- **Data API 10k units/day default.** Upload = 1600 units.
- New OAuth apps quota-locked to unlisted until Google audit (free, ~1 week).
- video-use **runs a real browser** — 500MB+ RAM per session, LLM tokens per action.
- YouTube detects automation. video-use for research/read ONLY. Never publish via automation.
- video-use is young (early 2025 project). Pin a version.
- YouTube Analytics API has separate scopes from Data API — check both enabled.

## Links
- YouTube Data API: https://developers.google.com/youtube/v3
- YouTube Analytics API: https://developers.google.com/youtube/analytics
- video-use: https://github.com/browser-use/video-use
- browser-use: https://github.com/browser-use/browser-use
