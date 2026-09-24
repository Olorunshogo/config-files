---
name: no-unprompted-installs
description: "Never install toolchains, system packages, or services the user didn't provide or ask for, including from subagents"
metadata:
  type: feedback
---

Never install, reinstall, or rely on system-level dependencies (language toolchains like rustup/cargo, Postgres, Redis, CLI tools) that the user did not explicitly provide or ask for.
This includes side effects of trying to unblock a build or test step.
In the user's words: "dont install what i dont send you. that way, this will not work on my pc."

**Why:** the user keeps their machine set up exactly how they want it, sometimes with a toolchain deliberately removed.
A background subagent once reinstalled a removed toolchain to verify a build, and silently re-patched the shell rc files, undoing the user's choice.

**How to apply:**
- If a task needs a missing tool, stop and ask instead of running an installer (`apt`, `brew`, `curl ... | sh`, etc.).
- When briefing any subagent that may run builds, tell it not to install toolchains and to report a missing-tool blocker instead.
- Don't stand up throwaway infra (a scratch database container) to verify work. Use what the user already runs. See [[verify-against-live-backend]].
- Running existing commands (`cargo check`, test suites) is fine. The issue is adding new system dependencies.
