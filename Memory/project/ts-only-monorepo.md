---
name: ts-only-monorepo
description: "TypeScript-only monorepo convention; metro.config.js is the one sanctioned JS file"
metadata:
  type: project
---

In a TypeScript monorepo (web + React Native/Expo apps), every file is TypeScript.
The one unavoidable exception is the mobile app's `metro.config.js`: Metro loads its config before any transformer exists, so there is no way to author it in TS.

**Why:** a mixed `.js`/`.ts` tree means lint, typecheck, and path aliases each need a second code path for the untyped files.

**How to apply:** write new config files as `.ts` wherever the tool supports it (`vite.config.ts`, `drizzle.config.ts`).
If a tool genuinely can't load a TS config, write it as JS with a header comment saying why.
Never silently add `.js` files.
