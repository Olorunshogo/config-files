---
name: rust-explicit-return
description: "User wants explicit `return` in Rust everywhere; allow clippy::needless_return instead of changing the code"
metadata:
  type: feedback
---

The user writes explicit `return` statements in Rust on purpose, including for a function's final expression.
`clippy::needless_return` is warn-by-default, so under a `-D warnings` gate it becomes an error.
The fix is to allow that one lint, not to change the style.

**Why:** explicit returns read more clearly to the user, and they don't want a lint gate forcing that style away.

**How to apply:**
- Always use explicit `return`, including for the final expression.
- In a project whose gate is `-D warnings`, allow just this lint: `[lints.clippy] needless_return = "allow"` in `Cargo.toml`, or a crate-level `#![allow(clippy::needless_return)]`.
- Keep the rest of the `-D warnings` gate, because it still catches real bugs. Only this one style lint is the objection.
