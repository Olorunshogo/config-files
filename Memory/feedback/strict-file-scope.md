---
name: strict-file-scope
description: "Only edit files the user explicitly authorized; never fix unrelated pre-existing breakage to force a green build"
metadata:
  type: feedback
---

Only edit the files the user explicitly authorizes for a task.
Don't modify unrelated files, and don't fix pre-existing breakage elsewhere just to make a build pass.

**Why:** editing out-of-scope files to force `cargo build` green was treated as overreach and had to be reverted.

**How to apply:** if a permitted change can't compile without touching an out-of-scope file, stop and present options instead of silently widening scope.
Verify authorized files in isolation where possible (e.g. `rustc --edition 2024 --crate-type lib <file>`).
