---
name: multi-tenant-saas-decisions
description: "Architecture decisions to settle before writing code in a national-scale multi-tenant SaaS, plus the scale ambition that drives them"
metadata:
  type: project
---

**Scale ambition:** a multi-tenant school-management SaaS aimed at national coverage (organised region by region, as a single source of truth), built to international standard with cross-border expansion expected.
It is not a "fine for a few hundred tenants" product.

This raises the weight of tenancy isolation, data residency, i18n/locale, curriculum and grading abstraction, government reporting, and compliance (local data-protection law now, GDPR-class later).

**How to apply the ambition:** treat country-specific assumptions (payment provider, SMS provider, currency, national exam boards, term structure, national ID) as pluggable adapters behind interfaces, not hardcoded core.
Prefer decisions that stay additive at 10,000+ tenants across several countries.

**Decisions to settle before the first line of product code** (each is cheap now and structural later):
1. **Per-tenant branding depth.** Recommended: runtime CSS-variable theming (tenant supplies a brand hue and logo, SSR emits token overrides), with template choice deferred but schema-reserved (e.g. a `public_template` column), and fully custom markup ruled out. Follow-on rule if accepted: no component ever hardcodes a Tailwind colour.
2. **Cookie `Domain` scope.** Host-only per subdomain (recommended, isolated by default) versus shared across the parent domain. This is a `Set-Cookie` attribute in the first auth handler.
3. **RLS mechanism.** If the architecture doc claims row-level security, either adopt it properly (a mandatory tenant-context wrapper plus a non-superuser DB role) or drop the claim. Don't leave it documented but unimplemented.
4. **Token delivery shape.** Have the login endpoint both set cookies and return tokens in the body, so a mobile client with no server-side proxy has a path. That costs one line now instead of an auth refactor later.

Record each answer as a locked decision in the repo's context doc before writing auth.
