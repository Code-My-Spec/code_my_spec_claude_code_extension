---
name: wix
channel: content
loop_fit: [acquisition, activation, monetization]
primary_mcp_status: official-native-connector
requires_server_install: false
requires_deploy: false
---

# Wix

## What it is
Wix CMS + CRM + store via the **official Wix MCP** — a native built-in connector in Claude. Zero install, zero `.env`, Wix handles OAuth and hosts the MCP on their own infrastructure.

## Unlocks
- Activities: "draft weekly blog post as Wix draft," "audit product catalog," "weekly new-contacts review," "bookings pipeline check," "blog post SEO field edits"

## Prerequisites
- A Wix account with admin access to the site(s) to expose

## Install steps
1. Open Claude (Desktop or Code) → Settings → Connectors → find **Wix** in the list.
2. Click Enable / Connect.
3. OAuth browser flow prompts — sign in to Wix, authorize.
4. Grant the specific Wix site(s) you want exposed. If multi-site, repeat per site.
5. Done.

## .env requirements
None. Connector manages auth.

## Validation
Ask Claude: "Using the Wix connector, list my 5 most recent blog posts." Expect JSON/table with post IDs and titles.

## Conventions to seed
Write `marketing/conventions/content.md` (create or merge):

```markdown
# Content conventions (Wix)

## Drafting flow
- New post → Wix draft first; never publish directly from the MCP.
- SEO fields (title, description, slug, OG image) filled in before publish.

## Tagging
- Use existing Wix tags; don't create new ones without intent.
- Max 3 tags per post.

## Images
- Upload to Wix Media Manager via the editor; reference by URL in draft body.
- Alt text required on all images.
```

## Gotchas
- Wix Studio (newer dev-oriented product) has fuller MCP coverage than classic Wix Editor sites.
- Scoped per-site — multi-site users authorize each separately.
- If user has multiple Wix sites, clarify which is the marketing target.
- Programmatic non-Claude access needs Wix REST API directly (different setup).

## Links
- Wix MCP: https://www.wix.com/studio/developers/mcp-server
- Docs: https://dev.wix.com/docs/api-reference/articles/wix-mcp/about-the-wix-mcp
