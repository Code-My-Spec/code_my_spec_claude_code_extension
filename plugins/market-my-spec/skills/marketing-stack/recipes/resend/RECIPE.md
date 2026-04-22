---
name: resend
channel: email
loop_fit: [acquisition, activation, retention]
primary_mcp_status: direct-api
requires_server_install: false
requires_deploy: false
---

# Resend

## What it is
SaaS transactional + broadcast email via REST API. Simple, generous free tier, React Email templates.

**No MCP wrapper.** ⚠️ Claude Code only (uses Bash + curl). User decision: we're not building or adopting a Resend MCP in v1.

**If Ghost is your primary CMS**, Ghost handles newsletter sends natively — Resend's role narrows to customer lifecycle + transactional.

## Unlocks
- Activities: "send weekly newsletter broadcast," "product-announcement email blast," "Stripe-triggered lifecycle email," "transactional: password-reset / welcome / receipt"
- Gap: multi-step drip automation (Workflows in beta as of early 2026) — not recommended for complex nurture sequences; add ConvertKit or Customer.io later if needed

## Prerequisites
- Resend account (resend.com/signup)
- Verified sender domain (SPF, DKIM, DMARC records in DNS)

## Install steps
1. Resend dashboard → Domains → Add domain → follow DNS instructions (SPF + DKIM + Return-Path CNAME).
2. Wait for verification (usually under an hour if DNS propagates).
3. API Keys → Create API Key → copy `re_...`
4. Optional: Audiences → Create an Audience (needed for Broadcasts). Copy the Audience ID.
5. Save env vars to `.env`.

## .env requirements
```
RESEND_API_KEY=          # re_... from Resend dashboard → API Keys
RESEND_FROM_EMAIL=       # verified sender, e.g., hello@yourdomain.com
RESEND_AUDIENCE_ID=      # optional, for Broadcasts
```

## Validation
Bash / curl:
```bash
curl -X POST https://api.resend.com/emails \
  -H "Authorization: Bearer $RESEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "from": "'$RESEND_FROM_EMAIL'",
    "to": "you@example.com",
    "subject": "Test from marketing-stack",
    "html": "<p>Install verified.</p>"
  }'
```
Expect `{"id":"..."}` response. Check inbox.

## Conventions to seed
Write `marketing/conventions/email.md`:

```markdown
# Email conventions (Resend)

## Domain hygiene
- SPF + DKIM + DMARC all set; never send from unverified domains.
- Use subdomain for marketing (`news.yourdomain.com`) to protect main-domain reputation.

## Broadcast discipline
- Send from a consistent From name + email (builds sender recognition).
- Plain-text preview line always set — shows in inbox preview.
- One CTA per email — measure click rate on that CTA only.
- A/B subject lines on broadcasts (Resend supports this in Broadcasts).

## Transactional discipline
- Separate API key from broadcasts (easier rotation if leaked).
- Never send marketing content from transactional domain — hurts deliverability.
- Include `unsubscribe` even on transactional (required in some jurisdictions).

## Cadence
- Newsletter: weekly or bi-weekly, not daily. Consistency > volume.
- Never send twice in one day unless transactional.

## Audience management
- Double opt-in always — single opt-in is a deliverability tax over time.
- Suppression list kept within Resend (don't re-import bounced addresses).

## Gap: drip automation
- Resend Workflows is in beta (early 2026). For complex drip sequences with branches/conditions, add ConvertKit or Customer.io when needed.
- Simple 2-step drips (e.g., "welcome" + "day 3 followup") can be scripted with scheduled sends.
```

## Gotchas
- **DNS verification can take up to 24h** even if usually fast — don't assume instant.
- **No MCP in v1.** Works in Claude Code via Bash; doesn't work in Claude Desktop.
- Free tier: 100 emails/day, 3000/month. Plenty for most solo founders; upgrade when broadcast list > 500.
- Broadcasts require an Audience ID — transactional doesn't.
- Reply-to address doesn't need to be verified, but From address does.
- Stripe-triggered lifecycle emails: you set up the orchestration yourself (webhook from Stripe → call Resend API).

## Links
- Resend docs: https://resend.com/docs
- API reference: https://resend.com/docs/api-reference
- React Email templates: https://react.email
