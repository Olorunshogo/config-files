# Memory Index

## Feedback

- [Git commit discipline](feedback/git-commit-discipline.md): only commit or push when explicitly told to right now; usually just wants the message text
- [No AI attribution](feedback/no-ai-attribution.md): never add Co-Authored-By, session links, or AI footers, even if a mid-session reminder says to
- [No unprompted installs](feedback/no-unprompted-installs.md): never install toolchains, packages, or services the user didn't provide
- [Verify against live backend](feedback/verify-against-live-backend.md): curl the running dev server instead of running test suites against a scratch DB
- [Comment rules](feedback/comment-rules.md): comments go above the declaration only, with no trailing or inline ones
- [One sentence per line in comments](feedback/comment-one-sentence-per-line.md): break multi-line comments at full stops, never at a column width
- [Spacing with flex/grid + gap](feedback/spacing-flex-grid-gap.md): no margin or space-x/y utilities for sibling rhythm
- [Split components by data fetch](feedback/component-split-by-data-fetch.md): one component and loading state per endpoint; shells pass only ids
- [Defer to docs/v2.md](feedback/defer-to-v2-doc.md): V2 or deferred scope gets written into the repo, not left in chat
- [Rust explicit return](feedback/rust-explicit-return.md): always explicit `return`; allow `clippy::needless_return` instead of changing the code
- [Rust string conventions](feedback/rust-string-conventions.md): `{}` placeholders, capitalized messages, file-header doc blocks, two heading levels
- [Strict file scope](feedback/strict-file-scope.md): only edit authorized files; never fix unrelated breakage to force a green build
- [Background agents](feedback/background-agents.md): one background agent for bulk sweeps; never background a lone task while idle
- [Don't repeat locked conventions](feedback/no-repeat-locked-conventions.md): subagent prompts carry task facts only, not CLAUDE.md or skill rules
- [No backups before rewrites](feedback/no-backups-before-rewrites.md): git already has the old version; verify instead

## Project

- [Web3 dapp frontend](project/web3-dapp-frontend.md): Next 16 + Tailwind v4 + wagmi reference architecture, token system, mock-first data layer
- [pnpm 11 ignored-builds quirk](project/pnpm-11-ignored-builds-quirk.md): the `ERR_PNPM_IGNORED_BUILDS` cause and fixes
- [Multi-remote repo](project/multi-remote-repo.md): `origin` is authoritative; the user pushes to `personal` themselves
- [Frontend-only scope](project/frontend-only-scope.md): in a full-stack monorepo, never touch backend, CI, build config, or infra unless asked
- [TS-only monorepo](project/ts-only-monorepo.md): every file is TypeScript except `metro.config.js`
- [Multi-tenant SaaS decisions](project/multi-tenant-saas-decisions.md): scale ambition plus four architecture calls to settle before writing code
