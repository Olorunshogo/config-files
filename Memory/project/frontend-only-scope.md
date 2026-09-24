---
name: frontend-only-scope
description: "In a full-stack Nx monorepo where the user owns the frontend, never touch backend/CI/build-config/infra unless asked"
metadata:
  type: project
---

In a full-stack monorepo where the user's role is frontend, work is frontend-only unless they explicitly ask otherwise.

**In scope:**
- Frontend apps under `apps/`
- The shared UI package and shared theme/Tailwind config
- The frontend's API client library, even if it has a generic name like `libs/<name>-api`. Read it to confirm.
- `docs/frontend/`
- Occasional root `package.json` edits

**Out of scope, even incidentally via a merge:**
- The backend app and backend-only libs
- `.github/` workflows
- Nx/build config: `nx.json`, `project.json`, `.nx/`, `tsconfig.base.json`
- Infra/deploy: `docker-compose.yml`, Dockerfiles, `deploy/`
- `docs/backend/`
- `pnpm-workspace.yaml`
- `pnpm-lock.yaml`, except as an incidental result of a legitimate frontend dependency change

**Why:** during large merges from shared branches, backend/infra changes rode along with the frontend changes and had to be reverted more than once.

**How to apply:** before merging an upstream branch or making a broad sweep, diff against the out-of-scope paths and exclude them.
If a merge conflict touches an out-of-scope file, keep the pre-merge (ours) version.
