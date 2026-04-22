# market-my-spec

Use Claude Code as your marketing strategist, then as your daily operator.

- `/marketing-strategy` — guided 8-step strategy flow. Interviews you, dispatches research agents, produces positioning, messaging, channels, and a 90-day plan.
- `/daily-plan` — picks today's 1-3 marketing activities from your strategy, points you at the skills that execute them, and keeps your activity roster honest (weekly review, gap detection, project-local skill scaffolding, archival of dead activities).
- `/marketing-stack` — sets up the marketing infrastructure your strategy calls for (MCPs, API credentials, plugin dependencies, minimal conventions). Recipe-based, MCP-first, `.env`-only secrets. 17 recipes covering Reddit, Wix, Ghost, WordPress, Stripe, HubSpot, claude-seo, GSC, GA4, Postiz, Meta Ads, Facebook, Instagram, LinkedIn, Twitter/X, YouTube, Resend.

Industry-agnostic — works for software founders, consultants, trades, services, and B2C operators.

## Install

From a Claude Code session:

```
/plugin marketplace add Code-My-Spec/plugins
/plugin install market-my-spec@codemyspec
```

## The flow

1. **Strategy first** — `/marketing-strategy`. Full 8-step flow on first run; iteration mode on later runs. Produces `marketing/01_current_state.md` through `marketing/08_plan.md`.
2. **Infrastructure setup** — `/marketing-stack`. Reads the strategy, installs the recipes its channels call for (Reddit, Ghost, Stripe, HubSpot, etc.). `.env`-only secrets, reversible installs. Writes `marketing/infrastructure.md` as the source of truth for what's wired up.
3. **Daily execution** — `/daily-plan`. Reads the strategy + infrastructure + activity roster; picks today's 1-3 activities; logs to `marketing/daily/YYYY-MM-DD.md`.
4. **Weekly re-tune** — `/daily-plan review`. Hit-rate analysis, loop-shift check, roster adjustments.
5. **As needed** — `/daily-plan add <name>` to scaffold a new activity, `/daily-plan archive <name>` to bench an unused one, `/marketing-stack install <recipe>` when a new channel goes live, `/marketing-stack fix <recipe>` when an integration breaks.

## The 8 steps

| # | Step | Mode | Framework anchors |
|---|---|---|---|
| 1 | Current state | Interview | Mom Test (Fitzpatrick), Shape Up appetite/no-gos, Lean Canvas |
| 2 | Jobs & segments | Interview | Moesta Switch Interview, Ulwick Outcome-Driven Innovation |
| 3 | Persona research | Research agents | Verbatim VOC mining; vertical-specific sources; confidence rubric |
| 4 | Beachhead | Synthesis | Moore's 9-point checklist, Aulet graduation criteria |
| 5 | Positioning | Synthesis + light research | Dunford's 5-component canvas |
| 6 | Messaging | Synthesis | Wiebe / Copyhackers VOC mining; Harry Dry specificity |
| 7 | Channels | Synthesis + light research | Weinberg Bullseye, 24-channel 2026 list |
| 8 | 90-day plan | Synthesis | Shape Up 6-week cycles, Hacking Growth North Star |

## Artifacts

Writes to your project's `marketing/` directory:

```
marketing/
├── 01_current_state.md           ← produced by /marketing-strategy
├── 02_jobs_and_segments.md
├── 03_personas.md
├── 04_beachhead.md
├── 05_positioning.md
├── 06_messaging.md
├── 07_channels.md
├── 08_plan.md
├── research/
│   ├── persona_<segment>.md
│   ├── alternatives.md
│   ├── competitor_positioning.md
│   └── channel_<name>.md
├── activities.md                 ← produced by /daily-plan (roster)
├── operating_rhythm.md           ← updated by /daily-plan review
└── daily/
    └── YYYY-MM-DD.md             ← one file per daily run
```

Scaffolded activities become real skills in `.claude/skills/<name>/` in the project (not user-global) so they're committable alongside the strategy.

## Business types supported

Adapts examples, research sources, channel defaults, and metrics by type:

- **Software / SaaS / dev tools**
- **Local trades** (granite, HVAC, roofing, etc.)
- **Consulting / professional services**
- **Prosumer / creator**
- **B2C physical / DTC**
