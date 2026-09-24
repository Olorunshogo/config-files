---
name: git-commit-discipline
description: "Only run git commit or push when the current message explicitly asks for it; usually the user just wants the message text"
metadata:
  type: feedback
---

Only run `git commit` when the user's current message explicitly asks for that exact action, right now.
Most of the time the user wants the commit message text only, and runs the commit themselves.
Never run `git push` without explicit approval either.

**Why:** the user wants final control over what lands and when.
Unprompted commits have happened before, and one carrying AI attribution trailers reached a shared `main` branch and had to be force-pushed away.

**How to apply:**
- Do the work (including conflict resolution), run typecheck/lint/build/tests, and leave changes staged or resolved but uncommitted.
- "Give me a commit message" means output the message text in the response. Nothing more.
- Commit only on an explicit imperative in the current message ("commit this", "go ahead and commit"), not when the user asks for a message or says a step is "ready."
- A prior "commit as X" or "push to Y" authorises that one action, not a standing licence.
- Never push unprompted, especially to shared branches like `main` or `develop`.
- When a commit IS made: sign it (`git commit -S` or configured signing), and use a single line with a conventional-commit prefix (`feat:`, `fix:`, `refactor:`, `chore:`, `test:`, `docs:`, `perf:`, `style:`), or the project's own convention from `CONTRIBUTING.md`.
- Never add AI attribution. See [[no-ai-attribution]].
