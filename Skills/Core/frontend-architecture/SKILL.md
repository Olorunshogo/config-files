---
name: frontend-architecture
description: Component and data-architecture conventions for frontend work, framework-agnostic (React or Vue) - splitting components by data-fetch boundary, content-as-data for pages and long-form documents, and centralizing reusable animation tokens. Distinct from coding-style (formatting/typing rules) and modal-animations (modal-specific animation choice).
---

# Frontend Architecture

Conventions for how to shape frontend code, not how to format it - see the `coding-style` skill for formatting/typing rules and `modal-animations` for modal-specific animation choice. Add a new convention here as it's noticed in a reference project, rather than scattering it into a one-off note.

---

## 1. Split components by data-fetch boundary, not just visual layout

Any region of UI backed by its own API endpoint gets its own component that fetches its own data and owns its own loading/error state. A shell/layout component never fetches and never receives the fetched object as a prop to redistribute - it only provides the minimal id(s) children need, via context (React `createContext`, Vue `provide`/`inject` or a composable).

**Why:** a parent that fetches everything upfront and hands pieces down through props means one slow endpoint blocks the entire page's loading state, causes prop drilling into children that shouldn't be coupled to the parent's shape, and re-renders every child whenever any field on the shared object changes - even fields that child doesn't use.

**Worked example** (from a senior dev's review of a property-details page): the page mixed "property details" (images, price, description) and "assignment area" (which agents are assigned, with remove/reassign actions) in one component, fed by one bundled `property` object passed down as a prop. The fix mirrored an existing `DashboardLayout` + sidebar pattern already in that codebase:

- `PropertyDetailsLayout` (shell) - provides `propertyId` via context, does no fetching, just arranges regions.
- `PropertyMainDetails` - reads `propertyId` from context, fetches core listing data itself, owns its own skeleton/error state.
- `PropertyAssignmentArea` - reads `propertyId` from context, fetches assignment data itself (a genuinely separate endpoint), owns its own loading/error state, hosts the assign/reassign/revoke actions.

**How to apply:** before splitting, confirm with the actual backend which pieces really are separate endpoints - don't split further than the API already does. When multiple regions do come from one combined endpoint, one component fetching once and passing that slice down is correct; the rule is about independently-sourced resources, not splitting for its own sake.

---

## 2. Content-as-data for pages

Page components stay pure composition: they arrange shared components and feed them from a co-located `content.ts` (or `.ts` data module), rather than hardcoding copy/props inline in the template/JSX. This keeps a page scannable as "what sections, in what order" and makes copy edits a data change, not a markup change.

**Example** (Next.js marketing homepage, from a reference repo): `page.tsx` imports shared section components (`PhotoHero`, `StatsBand`, `PersonaInviteBand`, ...) and a `content.ts` exporting the copy/data for each (`HERO`, `STATS`, `PERSONA_INVITE`, ...), and the page body is just those components fed by those constants - no inline strings, no inline arrays of props.

---

## 3. Long-form/legal documents as data, rendered by one shared component

A document that varies by role or version (terms of service, an agent agreement, a privacy policy) is modeled as a typed data structure (sections, blocks, inline content - not markup/JSX), stored one file per document, collected in a registry keyed by slug. A single generic renderer component (e.g. `LegalDocumentView`) consumes any document in the registry; one dynamic route (e.g. `/legal/:slug`) looks the document up and renders it. Adding a new document (a new role's terms, a policy revision) is one data file and one registry entry - no new route, no new component.

**Why data instead of markup:** the same object can later feed a signup consent record, an email, or a PDF export with no rewrite, and a `version` field on the document can be bumped whenever an obligation changes so a stored consent can't silently point at text the user never saw.

**Where the per-role mapping lives:** a small `ROLE_X_SLUG` map (e.g. `ROLE_TERMS_SLUG: { buyer: "buyer-terms", agent: "agent-terms" }`) sits next to the registry, read by signup/consent flows to link and record the right document per role - mirroring how a role-to-config map for signup itself might already work elsewhere in the same codebase.

**How to apply in a Nuxt/Vue context:** the same shape works unchanged (the type/registry/mapping are framework-agnostic data); only the renderer and the dynamic route are Vue-flavored (`pages/legal/[slug].vue` + a `LegalDocumentView.vue`).

---

## 4. Reusable animation tokens, not inline animation objects

Animation values (`Variants`, `Transition`, spring presets, durations, easings) live in one shared file (e.g. `lib/motion/variants.ts`), each named for the job it does ("fadeUpVariants", "springPanel"), not the values it uses. Components import from there; a component never declares an inline `initial`/`animate`/`exit` object or a one-off `Variants`. Pair with a thin wrapper component (e.g. `RevealOnView`) for the common case (scroll-triggered entrance, staggered by index) so most call sites need zero animation code of their own.

**Framework note:** this pattern (declarative `Variants`/`Transition`, `AnimatePresence`, `whileInView`, spring transitions) is not React-specific - `motion-v` is a Vue-native port of the same API (`motion`/formerly `framer-motion`), so the same shared-tokens file shape works in a Nuxt project. Reserve GSAP (imperative timelines) for orchestration that doesn't fit the declarative model - e.g. a dialog engine's enter/exit sequencing - rather than mixing both approaches for the same element.
