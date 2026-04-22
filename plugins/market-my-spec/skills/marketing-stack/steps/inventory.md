# Inventory mode (default `/marketing-stack`)

Show the user what infrastructure is installed, what the strategy calls for, and what's missing. Output a short prioritized to-do.

**Time in user's mouth: under 3 minutes.**

## Phase 1 — Gather

In parallel, read:

- `marketing/07_channels.md` — which channels are active / middle-ring
- `marketing/04_beachhead.md` — which loop is primary (for install-order priority)
- `marketing/infrastructure.md` if present — prior blueprint
- `marketing/activities.md` if present — which recipes are referenced by the roster
- `~/.claude/plugins/installed_plugins.json` — installed plugins
- `~/.claude.json` OR `~/.claude/settings.json` OR project-local `.mcp.json` — registered MCPs
- The recipe inventory in `SKILL.md` (the table) — canonical list of recipes

## Phase 2 — Classify each recipe

For each recipe in the V1 inventory (17 items), determine status:

- **ready** — MCP/plugin registered, creds in `.env` or connector-auth'd, strategy calls for it
- **setup-pending** — partially installed (e.g., MCP registered but no creds yet, or server-side plugin install pending)
- **not-installed-needed** — strategy calls for it, nothing set up
- **not-installed-nice-to-have** — strategy doesn't explicitly call for it, but it complements what's there
- **out-of-scope** — strategy rules it out or it's actively rejected in `07_channels.md`
- **blocked** — was working, now broken (creds expired, MCP unreachable) — detected by reading prior blueprint + actual state

**Detection heuristics:**

| Recipe | "Is it installed?" signal |
|---|---|
| `wix` | Check `~/.claude/settings.json` / connector config for Wix connector enabled |
| `ghost` | `~/.claude.json` has `ghost` or `@fanyangmeng/ghost-mcp` MCP entry; `.env` has `GHOST_API_URL` + `GHOST_ADMIN_API_KEY` |
| `wordpress` | `~/.claude.json` has `wordpress` or `@automattic/mcp-wordpress-remote`; `.env` has `WP_API_URL` |
| `reddit` | `~/.claude.json` has `reddit-mcp-buddy`; `.env` has `REDDIT_CLIENT_ID` (for tier 2+) |
| `stripe` | `~/.claude.json` has `stripe` or `@stripe/agent-toolkit`; `.env` has `STRIPE_RESTRICTED_KEY` |
| `hubspot` | `~/.claude.json` has a hubspot MCP entry; `.env` has `HUBSPOT_PRIVATE_APP_TOKEN` |
| `claude-seo` | `~/.claude/skills/seo/SKILL.md` exists; `~/.config/claude-seo/google-api.json` exists |
| `postiz` | `~/.claude.json` has postiz MCP pointing at a URL; `.env` has `POSTIZ_URL` + `POSTIZ_API_KEY` |
| `facebook-ads` | `~/.claude.json` has brijr/meta-mcp or pipeboard-co/meta-ads-mcp; `.env` has Meta app creds |
| `resend` | `.env` has `RESEND_API_KEY` — no MCP to check |
| `youtube` | `.env` has `YT_REFRESH_TOKEN` — no MCP to check for Data API direct path |

**When in doubt, ask the user once.** Don't assume.

## Phase 3 — Present the inventory

Show the user a single table. Keep it scannable:

```
# Marketing stack — 2026-04-22

## Strategy signals
- Inner-ring channels: Reddit, Content (Ghost), SEO
- Middle-ring tests: Elixir Forum, LinkedIn (manual for now)
- Ruled out: Facebook Ads, TikTok, Pinterest

## Installed (ready)
| Recipe | Status | Notes |
|---|---|---|
| claude-seo | ready | GSC + GA4 wrapped via seo-google |
| reddit | ready | tier-3 auth on bot account |

## Needs attention
| Recipe | Status | Why | Action |
|---|---|---|---|
| ghost | setup-pending | MCP registered but no admin key in .env | `/marketing-stack fix ghost` |
| stripe | not-installed-needed | Strategy calls for revenue intelligence | `/marketing-stack install stripe` |
| hubspot | not-installed-needed | Strategy calls for CRM funnel review | `/marketing-stack install hubspot` |

## Strategy-aligned, not yet installed
- postiz — deferred (no daily social commitment yet)
- resend — already in use outside the plugin; bring into scope with `/marketing-stack install resend`

## Out of scope (per strategy)
- facebook-ads, twitter-x, youtube — strategy rules these out
```

## Phase 4 — Recommend next action

One sentence. The highest-priority missing piece, mapped to the inner-ring channel or bottleneck loop:

> "Next: `/marketing-stack install stripe` — strategy calls for weekly revenue review and that's the only unblockable piece today. Then regenerate the blueprint with `/marketing-stack blueprint`."

If nothing is missing, say so:

> "Infrastructure matches strategy. Regenerate `marketing/infrastructure.md` with `/marketing-stack blueprint` if it's older than a week."

## Phase 5 — Optionally update blueprint

If `marketing/infrastructure.md` is older than 7 days or has drifted from what's observed, offer to regenerate:

> "Blueprint last updated 2026-04-12. Regenerate now? (y/n)"

If yes, load `steps/blueprint.md` before exiting.

## Anti-patterns

- **Listing recipes without strategy context.** Inventory is always against `07_channels.md`. A generic "here's what's installed" is less useful than "here's what's installed vs what your strategy needs."
- **Asking the user what's installed.** Read the configs yourself. Only ask when detection is genuinely ambiguous.
- **Long recommendation lists.** One next action, not three. If there are multiple unblockable items, pick the highest-leverage.
- **Running install from inventory mode.** Inventory reports; it does not install. Point the user at the explicit `install` command.
