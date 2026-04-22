---
name: stripe
channel: revenue
loop_fit: [monetization, activation]
primary_mcp_status: official
requires_server_install: false
requires_deploy: false
---

# Stripe

## What it is
Stripe read-only MCP for marketing-relevant revenue intelligence. Uses the **official `@stripe/agent-toolkit`** with a restricted API key. Not finance — the marketing slice: new subscriptions, churn, MRR trend, attribution from Checkout metadata.

## Unlocks
- Activities: "Monday revenue standup — net new, churn, MRR delta," "map new subs to UTM source via Checkout metadata," "flag price-point experiments that moved conversion," "trials ending this week"

## Prerequisites
- A Stripe account
- Admin access in Stripe Dashboard to create restricted keys

## Install steps
1. **Create a restricted API key:**
   - Stripe Dashboard → Developers → API keys → Create restricted key
   - Name: `marketing-stack-read`
   - Grant **READ** on: Customers, Subscriptions, Invoices, Checkout Sessions, Charges, Products, Prices, Coupons, Promotion Codes
   - Leave everything else **None**
   - Copy the `rk_live_...` (or `rk_test_...` for dev)
2. **Register the MCP:**
   ```bash
   claude mcp add --transport stdio stripe -s user -- npx -y @stripe/mcp --tools=read_only
   ```
   (The `@stripe/agent-toolkit` ships as `@stripe/mcp` on npm.)
3. Add env vars to `.env`.

## .env requirements
```
STRIPE_RESTRICTED_KEY=   # rk_live_... read-only restricted key
STRIPE_ACCOUNT_ID=       # acct_... optional, only for Stripe Connect setups
```

## Validation
Ask Claude: "Using the Stripe MCP, list 3 recent active subscriptions." Expect JSON with subscription IDs, customer IDs, prices.

## Conventions to seed
Write `marketing/conventions/revenue.md`:

```markdown
# Revenue conventions (Stripe + HubSpot)

## Attribution at Checkout (critical — set this day 1)
- Every Checkout Session creation sets `metadata[utm_source]`, `metadata[utm_campaign]` from the traffic source.
- Every Customer object sets `metadata[hubspot_contact_id]` when known, for identity resolution.

## HubSpot mirror
- Custom contact property `stripe_customer_id` mirrors the Stripe Customer ID.
- Reverse lookup "Stripe → HubSpot" is O(1) when both are set.

## MRR derivation
- MRR is NOT first-class in Stripe. Derive from:
  - Active subscriptions: sum(item.price.unit_amount × item.quantity) in cents
  - Normalize multi-currency via monthly FX snapshot
- Sigma query is the pragmatic choice for history.

## Monday standup
- Read: new subs (last 7d), churned subs (last 7d), trials ending (next 7d), MRR delta.
- Don't read: revenue by product (that's finance).

## Key rotation
- Rotate restricted key every 6-12mo or after any suspected leak.
- Use test-mode key (`rk_test_...`) during local dev.
```

## Gotchas
- 100 read req/sec live, 25/sec test. Paginate via `starting_after`.
- Attribution only works if `metadata` is set at Checkout creation. Retrofitting is impossible.
- `canceled_at` ≠ `ended_at`. First is user click, second is access lapse.
- Multi-currency: `unit_amount` is smallest unit (cents, yen, etc.) — no automatic FX.
- Restricted keys can be revoked / rotated without downtime.

## Links
- Source: https://github.com/stripe/agent-toolkit
- API reference: https://stripe.com/docs/api
- Restricted keys: https://stripe.com/docs/keys#limit-access
