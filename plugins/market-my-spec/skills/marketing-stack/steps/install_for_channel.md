# Install for a channel (`/marketing-stack install-for-channel <channel>`)

Bundle install. One command installs the recipes for a whole channel plus seeds the channel's conventions file. Users who just decided "I'm doing Reddit now" shouldn't have to know which individual MCPs to install.

## Phase 1 — Parse channel

Normalize: lowercase, hyphens. Recognized channels (from `SKILL.md` bundle table):

- `reddit`
- `social` (Postiz + optional facebook-ads)
- `seo` (claude-seo)
- `content-wix`
- `content-ghost`
- `content-wordpress`
- `email`
- `revenue` (stripe + hubspot)
- `crm` (hubspot)
- `youtube`

If the user passes an unrecognized channel, show the list. If the user passes a recipe name instead (e.g., `/marketing-stack install-for-channel ghost`), map it to the bundle (`content-ghost`) and confirm: "That'll install the ghost recipe plus seed content conventions. Ok?"

## Phase 2 — Check strategy alignment

Before installing, check `marketing/07_channels.md`:

- If the channel is in the **active/inner ring** or **middle ring**: proceed.
- If it's in **experimental**: confirm with the user — "07_channels.md puts `<channel>` in the experimental ring. Still want to install? (yes/no)"
- If it's in **ruled out**: warn hard — "`07_channels.md` explicitly rules out `<channel>`. Are you sure? This might be a strategy drift signal — consider `/daily-plan review` first."

Don't block. Users can override. But surface the friction.

## Phase 3 — Install recipes in bundle order

Bundle map (from `SKILL.md`):

```
reddit             → [reddit]
social             → [postiz, facebook-ads?]
seo                → [claude-seo]
content-wix        → [wix]
content-ghost      → [ghost, resend?]
content-wordpress  → [wordpress, resend?]
email              → [resend]
revenue            → [stripe, hubspot]   -- order matters for identity-resolution
crm                → [hubspot]
youtube            → [youtube]
```

For each recipe in the bundle:

1. Check if it's already `ready` — skip with a note.
2. If not, load `steps/install_recipe.md` for that recipe. Pass the single-recipe install through the same walkthrough.
3. After each recipe completes, return here and do the next one.
4. If a recipe fails validation, ask: "`<recipe>` didn't validate. Stop the bundle and fix, or continue with remaining recipes?" Default: stop.

**Optional recipes** (marked with `?` above) — ask inline:

- `social` → "Install the Meta Ads MCP too? Only needed if running paid campaigns. (yes/no/skip)"
- `content-ghost` → "Ghost handles newsletter sends natively. Install Resend too for transactional email and other lifecycle emails? (yes/no/skip)"
- `content-wordpress` → "WordPress doesn't do newsletters natively. Install Resend for email broadcasts? (yes/no/skip)"

## Phase 4 — Seed the channel conventions file

After all recipes are installed, write `marketing/conventions/<channel>.md`. Template depends on channel.

**For `reddit`** (example — this is the pattern for all channels):

```markdown
# Reddit conventions

Source: marketing-stack, channel install. Updated: YYYY-MM-DD.

## UTM format
- Campaign: topic slug, not page slug. Example: `?utm_source=reddit&utm_medium=comment&utm_campaign=agentic-coding-process`.
- Medium: always `comment` for comment links, `post` for submission links.

## Pacing rule
- Max 2-3 substantive comments per session; spread across the day.
- Never burst 6+ comments in one window (rate-limit trigger + community-perception red flag).

## Link discipline
- Never link to homepage. Always a specific content page earning the click.
- URL prefixes: `/pages/:slug`, `/blog/:slug`, `/documentation/:slug`. Bare slugs 404.

## Voice
- Answer first, link second. Substantive value up front.
- Em dashes → plain hyphens (Reddit spam filters).
- Two-comment strategy: short no-link comment for upvotes + reply with link for clicks.

## Touchpoint log
- Every engagement → one line in `marketing/touchpoints.md` with date, subreddit, thread URL, comment URL, link used.
- Enables weekly review to see which threads converted.

## Account hygiene
- Primary voice: [user's real account].
- Tools account (for reddit-mcp-buddy authenticated mode): dedicated bot account, not personal.
- Account tenure matters. Don't post from a freshly-created account.
```

The file is short, opinionated, editable. The user will adjust it over time.

Conventions file templates for each channel live in this step file's reference section below (or embedded in the recipe files under `## Conventions to seed` — pull from there).

## Phase 5 — Summary

After all recipes + conventions file are done:

> "Channel `<channel>` set up. Installed: `<list>`. Conventions seeded: `marketing/conventions/<channel>.md` — edit it to match your voice. Regenerate blueprint: `/marketing-stack blueprint`."

Also: if the user's `marketing/activities.md` roster has `gap` rows that map to this channel, offer to flip them to `active` now.

## Anti-patterns

- **Installing bundles without strategy check.** Silently installing a ruled-out channel is how infrastructure bloat starts.
- **Running all recipes sequentially without validation gates.** If recipe #1 fails, don't barrel through to recipe #5. Stop by default.
- **Ignoring optional recipes.** Ask every time, don't default "skip" silently. The user should make the call.
- **Not seeding conventions.** The conventions file is often more load-bearing than the MCP — it's what makes the resulting activities actually executable by daily-plan.
- **Over-templating conventions.** Short, opinionated, one page max. Users edit; don't over-write.
