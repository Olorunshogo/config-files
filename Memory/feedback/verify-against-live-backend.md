---
name: verify-against-live-backend
description: "Once the user has a backend dev server running, verify changes by curling it, not by running test suites against a scratch DB"
metadata:
  type: feedback
---

Once the user has a backend dev server running, verify backend changes by curling the live server directly.
Don't run `cargo test` (or any suite that spins up its own scratch database) as the default verification loop.
`cargo check` and `cargo clippy` are fine at any time, since they don't touch a database.

**Why:** the user was repeatedly interrupted by this, and was annoyed enough to add it as a written project rule.
Repeated builds also fight the running server for the Cargo target-dir lock ("Blocking waiting for file lock on build directory"), which visibly disrupts their workflow.

**How to apply:**
- Use `cargo check` / `cargo clippy --all-targets` as the correctness gate, then curl the live port.
- Run `cargo test` only if the user asks, or if there is no live server to verify against.
- If an authenticated flow needs a token/OTP/invite code, ask the user to paste the relevant log line. These are usually hashed at rest.
- New migrations or route wiring need a backend restart, so ask the user to restart, then resume curl verification.
- Background agents building new modules may still run their own tests internally before reporting back.
- Related: [[no-unprompted-installs]].
