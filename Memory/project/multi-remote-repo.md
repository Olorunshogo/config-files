---
name: multi-remote-repo
description: "In a repo with origin plus a personal fork remote, origin is authoritative; don't touch the personal remote unless asked"
metadata:
  type: project
---

Some team repos have several remotes: `origin` (the team's primary host, which may be Codeberg/Gitea rather than GitHub), sometimes a secondary mirror, and `personal` (the user's own fork).

**Rule:** `origin` is the source of truth.
Work, merges, and consolidation happen against `origin` first.
The user pushes to `personal` themselves, only once everything is consolidated on `origin`.

**Why:** in the user's words: "personal is not the reference point. origin is. its only when we have complete and its all consolidated that we usually push to personal."
In one case the team had moved active CI/CD and deploy work to the Codeberg remote, which was dozens of commits ahead of the GitHub one.

**How to apply:**
- When asked to fetch, merge, or push without a remote named, use `origin` only.
- Check `git remote -v` first, because the "primary" host may not be GitHub.
- Never fetch or push `personal` unless explicitly asked.
- Don't assume a secondary remote is deprecated. Confirm before deleting anything there.
