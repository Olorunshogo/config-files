---
name: web3-dapp-frontend
description: "Reference architecture for a Web3 dapp frontend: Next 16, React 19, Tailwind v4, wagmi v3, src/ layout, token system, mock-first data layer"
metadata:
  type: project
---

A Web3 prediction-style dapp with a marketing site and an app, sharing one Next.js repo with Foundry contracts.
Stack: Next 16, React 19, Tailwind v4, `motion`, `next-themes`, wagmi v3 + viem, TanStack Query, Vitest.
The architecture was ported from an earlier Tailwind v3 dashboard, so the token mechanism differs: `@theme` in `globals.css`, with no `withOpacity` shim.

**Layout:** frontend lives under `src/` (`src/app`, `src/components`, `src/lib`, `src/hooks`).
`contracts/`, `test/`, `scripts/`, `foundry.toml`, and `lib/forge-std` stay at the root.
The tsconfig `@/*` alias points to `./src/*`, and `vitest.config.ts` uses the same alias.

**Tokens** (`src/app/globals.css`):
- Dark theme is `:root` and light is `.light` (`next-themes` with `attribute="class"`, default dark, `enableSystem` false). Every colour and shadow has a light override.
- Semantic tokens: `--up` / `--down` (equal visual weight, never permanently bullish), `--signal`, `--warn`, `--on-up` / `--on-down`.
- `--section-px/py*` shift at `sm`/`lg`, so `px-section-px` is responsive on its own. `--navbar-h` gives `h-navbar` / `scroll-mt-navbar`, and `--container-page` (75rem) gives `max-w-container-page`.
- Fluid `--text-display..micro` clamp scale. Fonts come from `next/font`, and `--font-sans` swaps in one line.

**Components:**
- `CtaButton` + `CtaLink` share `ctaClasses()` (`variant="primary"|"secondary"`).
- `Section` is the one layout primitive, alongside `SectionHeading`.
- `Faq` is a data-driven accordion (`items` prop, `grid-rows` 0fr to 1fr, `inert` when closed, deep-link slug ids).
- Shared pieces include a marketing NavigationBar (with no wallet imports), an app Navbar, Footer, AmbientBackground, ThemeToggle, and Providers.
- Motion is modular: `src/lib/motion/{transitions,variants}.ts`, imported from `@/lib/motion`.

**Wallet:** wagmi + viem with a custom `WalletButton`, and no RainbowKit, for a bespoke identity on a single chain.
Chains come from the chain vendor's SDK.
`WagmiProvider` + `QueryClientProvider` mount only in the `(app)` route-group layout, so marketing pages carry no wallet code.

**Data layer:** screens read from `src/lib/app-data/`, which is TanStack Query hooks over a swappable data source.
`NEXT_PUBLIC_MOCK=1` is the default. Every screen has loading/empty/error states, so wiring the live SDK doesn't change any screen.

**Tooling:** `typecheck` is `next typegen && tsc --noEmit`, because Next 16's generated route types (`LayoutProps<"/">`) only exist after typegen.
See [[pnpm-11-ignored-builds-quirk]].
Follows [[spacing-flex-grid-gap]].
