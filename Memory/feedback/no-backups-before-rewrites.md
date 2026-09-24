---
name: no-backups-before-rewrites
description: "Don't copy a file to the scratchpad as a backup before rewriting it; git already has it"
metadata:
  type: feedback
---

When rewriting or replacing a file, skip the `cp file scratchpad/file.bak` step and go straight to the rewrite.

**Why:** the work is in git-tracked repos, so the previous version is already recoverable, and the backup step wastes round-trips.

**How to apply:** spend that effort on verification instead.
Prove a change with a command whose output settles it, not by eyeballing the diff.
