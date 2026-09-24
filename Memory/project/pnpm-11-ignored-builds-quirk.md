---
name: pnpm-11-ignored-builds-quirk
description: "pnpm 11 prints ERR_PNPM_IGNORED_BUILDS for unrs-resolver when the global allowBuilds value is a placeholder string; causes and fixes"
metadata:
  type: reference
---

**Symptom:** every `pnpm install` prints `ERR_PNPM_IGNORED_BUILDS` for `unrs-resolver`, even with it listed as a build dependency.

**Cause:** the global pnpm config has `allowBuilds.unrs-resolver` set to the placeholder string `"set this to true or false"` instead of a boolean.
Separately, `pnpm.onlyBuiltDependencies` in `package.json` is ignored in pnpm 11, where these settings live in `pnpm-workspace.yaml`.

**Impact:** usually none, because the prebuilt binary (`@unrs/resolver-binding-linux-x64-gnu`) is already present.

**Fixes:**
- Real fix: `pnpm config set --global allowBuilds.unrs-resolver true`. This is a global change, so leave it to the user.
- Add `verifyDepsBeforeRun: false` to `pnpm-workspace.yaml` to stop pnpm running an implicit, failing `install` (and dumping a stack trace) before every `pnpm run <script>`.

**Related setup notes from an npm to pnpm migration:** prettier with `eslint-config-prettier` last in the flat config, husky + lint-staged, validate-branch-name, `.editorconfig`, `.nvmrc`, and `[fmt]` in `foundry.toml`.
Guard Solidity hooks with `command -v forge` if Foundry may not be installed.
