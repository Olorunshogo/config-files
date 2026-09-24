---
name: workspace-setup
description: Scaffolds IDE config files (.vscode or equivalent) for a new repo based on the detected tech stack. Use when starting a new project or when a repo is missing workspace settings.
---

# Workspace Setup

When invoked, scan the repo, detect the tech stack and IDE, then create the appropriate IDE config files. Do not ask for confirmation - just detect and create.

---

## Step 0 - Default Scaffold Shape for a New Full-Stack Project

Only applies when scaffolding a brand-new monorepo from nothing (no `apps/`, `package.json`, or `Cargo.toml` yet) and the project is meant to have both a frontend and a backend. If the repo already exists, skip straight to Step 1 and just fill in the IDE config for what's already there.

Default to the Klassivox shape, an Nx + pnpm monorepo:

```
<repo>/
  Cargo.toml                    Rust workspace, one member: <name>-backend
  nx.json, package.json, pnpm-workspace.yaml, tsconfig.base.json
  apps/
    <name>-backend/               Rust/Axum crate (tenant/identity + domain API)
    <name>-web/                     console/dashboard (Vue/Nuxt)
    <name>-mobile/                    Capacitor/Vue app, if a direct-capture or native client is in scope
  packages/
    <name>-ui/{core,web,app}          shared UI, split like Klassivox's ui-core/-web/-app
  libs/
    shared/{theme,composables,validation}
    utils/
```

**Frontend-only or backend-only project:** skip whatever the other side doesn't need, don't scaffold it "just in case."
- Backend-only (a Rust API with no planned UI): skip `apps/<name>-web`, `apps/<name>-mobile`, `packages/<name>-ui/*`, and `libs/shared/theme` and `libs/shared/composables` (nothing consumes them). Keep `Cargo.toml`, `apps/<name>-backend`, and `libs/utils` only if something in the backend actually needs a shared TS utility (rare); otherwise skip the JS/TS root files (`package.json`, `nx.json`, `pnpm-workspace.yaml`, `tsconfig.base.json`) entirely and let it be a plain Cargo workspace.
- Frontend-only (no backend planned yet, or the backend is someone else's API): skip the root `Cargo.toml` and `apps/<name>-backend` entirely.

Ask the user once, before scaffolding, whether a mobile app is in scope; don't assume `apps/<name>-mobile` is needed just because the shape has a slot for it.

---

## Step 1 - Detect IDE

Check which editor the user is in:
- VS Code or Cursor: create `.vscode/`
- Zed: create `.zed/settings.json`
- Default to `.vscode/` if unknown

---

## Step 2 - Detect Tech Stack

Scan the repo root for these markers:

| Marker | Stack |
|---|---|
| `package.json` with `"next"` | Next.js |
| `package.json` with `"react"` (no next) | React / Vite |
| `package.json` with `"vue"` or `"nuxt"` | Vue / Nuxt |
| `package.json` with `"@nestjs/core"` | NestJS |
| `package.json` with `"express"` | Express |
| `Cargo.toml` | Rust |
| `Scarb.toml` or `*.cairo` files | Cairo / Starknet |
| `hardhat.config.*` or `foundry.toml` | Solidity |
| `pnpm-workspace.yaml` | Monorepo (pnpm) |
| `turbo.json` | Turborepo |
| `tailwind.config.*` | Tailwind CSS |

A project can match multiple markers - apply all relevant sections.

---

## Step 3 - Create `.vscode/settings.json`

One `.vscode/settings.json` at the repo root, always, regardless of how many stacks or apps the repo contains. Include the base config, then append every stack-specific section that matched, all merged into that single file.

### Base Config (always include)

```json
{
  // Note: Adjust the formatter below to the equivalent for your IDE if not using VS Code / Prettier
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.formatOnPaste": false,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "never"
  },
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "editor.rulers": [80],
  "editor.wordWrap": "off",
  "editor.linkedEditing": true,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": "active",
  "editor.inlayHints.enabled": "on",
  "editor.suggest.preview": true,
  "editor.acceptSuggestionOnEnter": "smart",
  "editor.quickSuggestionsDelay": 100,
  "editor.stickyScroll.enabled": true,

  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 300,
  "files.eol": "\n",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "files.exclude": {
    "**/.git": true,
    "**/.DS_Store": true,
    "**/node_modules": true
  },
  "files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/node_modules/**": true
  },

  "search.exclude": {
    "**/node_modules": true,
    "**/package-lock.json": true
  },

  "terminal.integrated.defaultProfile.linux": "bash",

  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,

  "explorer.fileNesting.enabled": true,
  "explorer.fileNesting.patterns": {
    "*.ts": "${capture}.js, ${capture}.d.ts",
    "package.json": "package-lock.json, .npmrc, .nvmrc, .node-version",
    ".eslintrc.*": ".eslintignore, .prettierrc, .prettierignore, .editorconfig, .lintstagedrc*"
  },

  "cSpell.words": []
}
```

### Stack-specific additions

**TypeScript / JavaScript (any JS project):**
```json
{
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "typescript.preferences.importModuleSpecifier": "non-relative",
  "typescript.preferences.quoteStyle": "single",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "typescript.inlayHints.parameterNames.enabled": "literals",
  "typescript.inlayHints.variableTypes.enabled": false,
  "typescript.inlayHints.functionLikeReturnTypes.enabled": false,
  "js/ts.autoClosingTags.enabled": false,

  "eslint.enable": true,
  "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
  "eslint.workingDirectories": [{ "mode": "auto" }],
  "eslint.run": "onSave",

  "prettier.requireConfig": true,
  "prettier.configPath": ".prettierrc",
  "prettier.useEditorConfig": false,
  "prettier.printWidth": 80,
  "prettier.tabWidth": 2,
  "prettier.useTabs": false,
  "prettier.singleQuote": false,
  "prettier.semi": true,
  "prettier.trailingComma": "es5",
  "prettier.bracketSpacing": true,

  "[javascript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[javascriptreact]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[typescriptreact]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[json]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[jsonc]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[css]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.wordWrap": "on"
  },

  "emmet.includeLanguages": {
    "typescriptreact": "html"
  },
  "npm.packageManager": "pnpm"
}
```

**Tailwind CSS:**
```json
{
  "tailwindCSS.experimental.classRegex": [
    ["cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"],
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ],
  "tailwindCSS.includeLanguages": {
    "typescript": "javascript",
    "typescriptreact": "javascript"
  },
  "tailwindCSS.validate": true
}
```

**Next.js (add to files.exclude and files.watcherExclude and search.exclude):**
```json
{
  "files.exclude": { "**/.next": true, "**/out": true },
  "files.watcherExclude": { "**/.next/**": true },
  "search.exclude": { "**/.next": true, "**/out": true },
  "explorer.fileNesting.patterns": {
    "next.config.*": "next-env.d.ts"
  }
}
```

**Monorepo (pnpm/Turborepo) - add to files.exclude and search.exclude:**
```json
{
  "files.exclude": { "**/cache": true, "**/artifacts": true },
  "search.exclude": { "**/cache": true, "**/artifacts": true }
}
```

**Rust (Cargo.toml present):**
```json
{
  "[rust]": { "editor.defaultFormatter": "rust-lang.rust-analyzer" },
  "rust-analyzer.checkOnSave": true,
  "rust-analyzer.cargo.features": "all"
}
```

**Solidity (hardhat or foundry):**
```json
{
  "[solidity]": { "editor.defaultFormatter": "NomicFoundation.hardhat-solidity" },
  "solidity.defaultCompiler": "hardhat"
}
```

---

## Step 4 - Create `.vscode/extensions.json`

One `.vscode/extensions.json` at the repo root, always. Include the base set plus every stack-specific recommendation that matched, all in that single file.

### Base recommendations (always)
```json
{
  "recommendations": [
    "streetsidesoftware.code-spell-checker",
    "usernamehw.errorlens",
    "eamodio.gitlens",
    "mhutchie.git-graph",
    "pkief.material-icon-theme",
    "mikestead.dotenv"
  ],
  "unwantedRecommendations": [
    "hookyqr.beautify",
    "ms-vscode.vscode-typescript-tslint-plugin"
  ]
}
```

### Stack-specific recommendations to add

**TypeScript / JavaScript:**
```
"esbenp.prettier-vscode"
"dbaeumer.vscode-eslint"
"ms-vscode.vscode-typescript-next"
"christian-kohler.path-intellisense"
"antfu.iconify"
"naumovs.color-highlight"
"auto-close-tag.fullMode"
```

**React:**
```
"dsznajder.es7-react-js-snippets"
```

**Vue / Nuxt:**
```
"Vue.volar"
"antfu.unocss"
```

**Tailwind CSS:**
```
"bradlc.vscode-tailwindcss"
```

**Next.js:**
```
"nextjs.vscode-nextjs"
```

**Rust:**
```
"rust-lang.rust-analyzer"
"tamasfe.even-better-toml"
"vadimcn.vscode-lldb"
```

**Cairo / Starknet:**
```
"starkware.cairo1"
```

**Solidity:**
```
"NomicFoundation.hardhat-solidity"
"tintinweb.solidity-visual-auditor"
```

---

## Step 5 - Create `.vscode/launch.json` (if applicable)

Only create this if a runnable dev server, or a Rust binary, is detected. One `.vscode/launch.json` at the repo root, always, with every matching config below listed together in `configurations`.

**Rust (Cargo.toml present, needs the `vadimcn.vscode-lldb` extension from Step 4):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Cargo: debug backend",
      "type": "lldb",
      "request": "launch",
      "cargo": {
        "args": ["build", "--bin=<binary-name>"]
      },
      "args": [],
      "cwd": "${workspaceFolder}"
    }
  ]
}
```
Replace `<binary-name>` with the crate's actual `[[bin]] name` from `Cargo.toml` (falls back to the package name when there's only one bin target).

**Next.js:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js: debug server-side",
      "type": "node-terminal",
      "request": "launch",
      "command": "npm run dev",
      "serverReadyAction": {
        "pattern": "started server on .+, url: (https?://.+)",
        "uriFormat": "%s",
        "action": "debugWithChrome"
      }
    },
    {
      "name": "Next.js: debug client-side",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000"
    },
    {
      "name": "Next.js: debug full stack",
      "type": "node-terminal",
      "request": "launch",
      "command": "npm run dev",
      "serverReadyAction": {
        "pattern": "started server on .+, url: (https?://.+)",
        "uriFormat": "%s",
        "action": "debugWithChrome"
      },
      "cascadeTerminateToConfigurations": ["Next.js: debug client-side"]
    }
  ]
}
```

**React / Vite:**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Vite: debug client",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:5173"
    }
  ]
}
```

**Node (Express / NestJS):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Node: debug server",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "node",
      "runtimeArgs": ["--inspect", "-r", "ts-node/register"],
      "args": ["src/main.ts"],
      "sourceMaps": true,
      "outFiles": ["${workspaceFolder}/dist/**/*.js"]
    }
  ]
}
```

---

## Step 6 - Post-creation

After writing all files:
- List which files were created
- Note which stack was detected
- Remind the user to update `cSpell.words` in `settings.json` with project-specific terms
- If a `.prettierrc` is missing, note that `prettier.requireConfig: true` will suppress formatting until one is added

---

## PR Summaries

When asked for a PR summary, use exactly this format - no extra sections, no attribution footer:

```markdown
## Summary

- **<Area>**: <What changed and why - specific, no em dashes>
- **<Area>**: <What changed and why>

## Test plan

- [ ] <Concrete verification step>
- [ ] <Concrete verification step>
```

Rules:
- Bold the area label, colon after it, then plain prose
- Use a hyphen (-) instead of em dash anywhere
- Do NOT append "🤖 Generated with [Claude Code](...)" or any attribution line
- Keep each bullet to one or two sentences max
- Test plan items must be concrete and checkable, not vague ("verify it works")
