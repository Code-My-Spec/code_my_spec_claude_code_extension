---
name: marketing-stack
description: Set up the marketing infrastructure your strategy calls for — MCPs, API credentials, plugin dependencies, minimal conventions — so the skills you use daily actually have something to run against. Reads marketing/07_channels.md to know which channels matter, then installs recipes per channel (Reddit, Wix, Ghost, WordPress, Stripe, HubSpot, claude-seo, Postiz, Meta Ads, etc.). MCP-first, .env-only secrets, reversible installs. Use when starting a new project, onboarding a new channel, or re-wiring infrastructure after a strategy shift. Also use to regenerate `marketing/infrastructure.md` — the source of truth for what's wired up.
user-invocable: true
argument-hint: [install <recipe> | install-for-channel <channel> | fix <recipe> | blueprint]
---

# Marketing Stack

Infrastructure setup for a strategy-owning founder. Sits between `/marketing-strategy` (the plan) and `/daily-plan` (the execution). The strategy tells you what channels matter; this skill wires up the APIs, MCPs, and credentials that make those channels runnable.

## Operating philosophy (load-bearing)

- **MCP-first.** If a good maintained MCP exists for a channel, that's the recipe. Why: cross-client portability (Claude Desktop + Code + Cursor), typed tools beat shell commands, secrets centralize. Direct-API via Bash is a documented fallback for gaps, flagged ⚠️ "Claude Code only."
- **`.env` only for secrets.** Never written into MCP config files, never into `settings.json`, never into recipe templates committed to git.
- **Install in service of strategy, never speculatively.** If `07_channels.md` doesn't mention Facebook, don't install facebook-ads. The strategy is the demand side; this skill is the supply.
- **Reversible.** Every install step has a documented undo. No hidden global state.
- **Credential-aware ordering.** One Google Cloud project covers GSC + GA4 + YouTube. One Meta app covers Facebook + Instagram. Install in the order that reuses credentials instead of re-auth-ing three times.
- **Server-side changes require user consent.** Installing the WordPress MCP adapter on the user's WP site touches their site. Always document + verify, never automate without explicit "yes."

## Modes

| Invocation | Mode | Step file |
|---|---|---|
| `/marketing-stack` | Inventory: what's installed vs what strategy needs | `steps/inventory.md` |
| `/marketing-stack install <recipe>` | Guided install for one recipe | `steps/install_recipe.md` |
| `/marketing-stack install-for-channel <channel>` | Bundle install: all recipes for a channel + minimal conventions | `steps/install_for_channel.md` |
| `/marketing-stack fix <recipe>` | Diagnose a broken/expired install + re-auth | `steps/fix_recipe.md` |
| `/marketing-stack blueprint` | Regenerate `marketing/infrastructure.md` | `steps/blueprint.md` |

**Progressive disclosure.** Do NOT read step files or recipe files upfront. Orient first, then load only what's needed.

## Step 0 — Orient (always, before loading any step file)

Do these in parallel:

1. **Check `marketing/` exists.** If not: "No strategy found. Run `/marketing-strategy` first. (You can still run `/marketing-stack install <recipe>` for a specific recipe without a strategy, but inventory mode needs one.)"
2. **Read `marketing/07_channels.md`** if present — what channels are in the active/middle ring.
3. **Read `marketing/infrastructure.md`** if present — the blueprint from a prior run.
4. **Read `marketing/activities.md`** if present — tells us which recipes are referenced by the roster.
5. **Scan `~/.claude/plugins/installed_plugins.json`** and `~/.claude/skills/` to know what's already installed (claude-seo, marketingskills, etc.).
6. **Check for existing MCP configs** — `~/.claude.json`, `~/.claude/settings.json`, or per-project `.mcp.json` — to see which MCPs are registered.
7. **Parse the argument** to choose mode.

Greet briefly — one sentence confirming mode — and load the matching step file.

## Available recipes

Each recipe lives at `recipes/<name>/RECIPE.md`. First read is on demand, not upfront. When a user says `install <name>` or `install-for-channel <channel>`, load the relevant recipe(s).

**V1 recipe inventory (17):**

| Recipe | Channel(s) | MCP status |
|---|---|---|
| `wix` | Wix CMS + CRM + store | ✅ Official Wix native connector in Claude |
| `ghost` | Ghost CMS + newsletter + memberships | ✅ `@fanyangmeng/ghost-mcp` |
| `wordpress` | WordPress CMS + WooCommerce | ✅ `WordPress/mcp-adapter` (server) + `@automattic/mcp-wordpress-remote` (client) |
| `reddit` | Reddit | ✅ `reddit-mcp-buddy` (karanb192) |
| `stripe` | Revenue intelligence (read) | ✅ Official `stripe/agent-toolkit` MCP |
| `hubspot` | CRM (read + write) | ✅ Community MCP + Private App token |
| `claude-seo` | SEO toolkit (audits, GSC, GA4, technical, schema, content) | ✅ Full plugin w/ bundled DataForSEO / Firecrawl / nanobanana MCPs |
| `postiz` | Social publishing hub (FB, IG, LinkedIn, X, YouTube, Reddit, TikTok, etc.) | ✅ Bundled MCP in postiz-app repo; requires deploy |
| `facebook-ads` | Meta Ads (Facebook + Instagram ads) | ✅ `brijr/meta-mcp` or `pipeboard-co/meta-ads-mcp` |
| `facebook-publish` | Facebook Page organic publishing | Routes through `postiz` (no separate install) |
| `instagram` | Instagram Business publishing + insights | Routes through `postiz` for publishing; Meta Graph direct via facebook-ads' app for insights |
| `linkedin` | LinkedIn personal + Company Page | Routes through `postiz` (direct is ⚠️ Bash-only fallback) |
| `twitter-x` | Twitter/X | Routes through `postiz` (direct is ⚠️ Bash + $200/mo) |
| `youtube` | YouTube publishing + research | ⚠️ Data API direct via Bash (Claude Code only); video-use as local Chromium tool |
| `gsc` | Google Search Console | Covered by `claude-seo`'s `seo-google` sub-skill; ⚠️ direct wrapper otherwise |
| `ga4` | Google Analytics 4 | Same — covered by `claude-seo` |
| `resend` | Email broadcast + transactional | ⚠️ Bash + REST (user decision: no custom MCP) |

## Channel → recipe bundles

When the user runs `install-for-channel <channel>`, install the recipe set below. Also seeds `marketing/conventions/<channel>.md` with minimal channel-specific patterns.

| Channel | Recipes (install order) | Conventions file |
|---|---|---|
| `reddit` | `reddit` | `marketing/conventions/reddit.md` |
| `social` | `postiz` → optional `facebook-ads` | `marketing/conventions/social.md` |
| `seo` | `claude-seo` (bundles GSC + GA4 support) | `marketing/conventions/seo.md` |
| `content-wix` | `wix` | `marketing/conventions/content.md` |
| `content-ghost` | `ghost` → optional `resend` | `marketing/conventions/content.md` |
| `content-wordpress` | `wordpress` → optional `resend` | `marketing/conventions/content.md` |
| `email` | `resend` (unless Ghost is primary CMS) | `marketing/conventions/email.md` |
| `revenue` | `stripe` → `hubspot` (install in this order for identity-resolution metadata pattern) | `marketing/conventions/revenue.md` |
| `crm` | `hubspot` | `marketing/conventions/crm.md` |
| `youtube` | `youtube` | `marketing/conventions/youtube.md` |

## Install order (cold-start across the stack)

For a new project with a complete strategy, recommended cold-start order:

1. **Google Cloud foundation** (covers GSC + GA4 + YouTube + PageSpeed + CrUX): install `claude-seo`, run its credential setup. One GCP project + service account + API key handles 5 later integrations.
2. **Primary CMS (pick one):** `wix` OR `ghost` OR `wordpress`. Warn if more than one, but allow (agencies legitimately run multiple).
3. **Social publishing hub:** `postiz` deploy → local or BYO URL. Once deployed, Postiz holds OAuth for FB/IG/LinkedIn/X/YouTube/Reddit/TikTok publishing.
4. **Meta app (one-time):** only if running Meta Ads OR if postiz deploy isn't happening yet. Covers `facebook-ads` + `instagram` + direct Graph fallback.
5. **CRM + revenue:** `hubspot` Private App token → `stripe` restricted key. **Seed identity-resolution metadata** — `metadata[hubspot_contact_id]` on Stripe Customer objects, `stripe_customer_id` custom contact property in HubSpot. Critical for "which MQLs converted to paid?" queries later.
6. **Email:** skip if Ghost is primary CMS (Ghost handles newsletters natively). Otherwise `resend` for broadcasts + transactional.
7. **Reddit:** `reddit` MCP with tier-3 creds on a dedicated bot account.
8. **YouTube:** only if the strategy includes YouTube (usually no for beachhead phase).

The `inventory` mode surfaces this order dynamically based on which recipes the user's strategy actually calls for.

## The blueprint file — `marketing/infrastructure.md`

Source of truth for what's wired up. Written and regenerated by the `blueprint` mode. Structure:

```markdown
# Infrastructure

Updated: YYYY-MM-DD

## Status summary
- Ready: N recipes
- Setup-pending: M recipes (auth needed / partial install)
- Not installed: K recipes (strategy-called but not set up)
- Blocked: L recipes (credentials expired or MCP unreachable)

## Recipes

| Recipe | MCP / integration | Status | Last verified | Notes |
|---|---|---|---|---|
| wix | Official Wix native connector | ready | 2026-04-22 | Connected via Claude connector settings |
| ghost | @fanyangmeng/ghost-mcp (stdio) | ready | 2026-04-22 | Admin API key in .env, key rotates: 2027-04 |
| ... |

## Conventions
- marketing/conventions/reddit.md
- marketing/conventions/social.md
- ...

## Credential-sharing map
(Generated live — what creds are shared across recipes.)

## Open issues
- facebook-ads: App Review pending (est. 2026-05-05)
- wordpress: mcp-adapter plugin not installed on site yet — last attempt 2026-04-20
```

## Integration with `/daily-plan`

`/daily-plan` reads `marketing/infrastructure.md` when picking activities. An activity whose recipe is `ready` is runnable; `setup-pending` or `blocked` means daily-plan surfaces "run `/marketing-stack fix <recipe>`" instead of picking it.

Activities in `marketing/activities.md` gain an optional **Infrastructure** column listing the recipes they depend on:

| Activity | Skill | Infrastructure | Loop | ... |
|---|---|---|---|---|
| Scan Reddit | `/scan-reddit` | `reddit` | Acquisition |
| Publish weekly post | `/draft-content` → Ghost | `ghost` | Acquisition |
| CRO audit | `/page-cro` → `/seo-page` | `claude-seo`, `ga4` | Activation |

The `blueprint` mode can optionally update activities.md's infrastructure column, filling in any gaps.

## Anti-patterns

- **Installing speculatively.** If the strategy doesn't call for a channel, don't install recipes for it. Bloat makes audits harder.
- **Writing secrets to MCP config files.** `.env` only. If a recipe's canonical install wants secrets in config, rewrite the install to use env-var interpolation from `.env`.
- **Skipping verification.** Every install ends with a validation call. "Install complete" without a verified tool call is a lie.
- **Automating server-side changes.** Installing the WP mcp-adapter plugin on the user's WordPress site requires their admin action. Document + verify. Never reach across that boundary.
- **Conflating stack with library.** This skill manages **infrastructure**. Plugin-skill inventory (marketingskills, Anthropic Marketing) belongs to `/marketing-library` (separate skill, later).
- **Promising health monitoring.** Ongoing credential-freshness checks are a separate concern, likely a separate skill. This skill's `fix` mode handles user-initiated "it broke," not continuous monitoring.

## What this skill does NOT do

- Define the strategy — that's `/marketing-strategy`.
- Curate playbook skills / plugins (marketingskills, Anthropic Marketing, etc.) — that's `/marketing-library` (future).
- Execute daily activities — that's `/daily-plan`.
- Run continuous health monitoring — separate concern, likely a future skill.
- Deploy Postiz (or other self-hosted tools) for the user — v1 caps at local docker-compose install OR bring-your-own URL. Hetzner deployment path is a future feature.
- Write content, draft posts, or run campaigns — that's the downstream skill each recipe enables.

---

Based on the argument, load the matching step file now. If no argument, load `steps/inventory.md`.
