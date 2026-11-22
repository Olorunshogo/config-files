---
name: bitcoin-oss-contribution
description: End-to-end playbook for contributing to open-source projects, tuned for Bitcoin/Rust repos (bdk, bdk-cli, rust-bitcoin, rust-miniscript, LDK, Bitcoin Core style review culture). Covers triaging and claiming an issue, planning a minimal fix, fork/upstream branch hygiene, proving the fix with tests, commits and CHANGELOG, PR descriptions, handling review rounds, rebases and conflicts, CI flakes, and post-merge cleanup. Use when the user wants to pick up an issue, write an issue comment, prepare/open/update a PR, answer reviewers, rebase, or understand review feedback on any open-source repo.
---

# Bitcoin / Open-Source Contribution Playbook

Goal: land correct, minimal, well-evidenced changes with as few review rounds as possible. In Bitcoin software a silent bug can lose funds or leak keys for real users, so "it compiles and CI is green" is not the bar. The bar is: reproduced, proven, scoped, and every claim verified.

The user's global rules always apply on top of this skill: plan before modifying files and wait for approval, never `git commit`/`git push` unless asked in the current message, signed single-line conventional commits, no AI attribution anywhere, PR/issue text as raw markdown in a fenced block, no em dashes.

If a project memory exists for the repo (e.g. `bdk-cli-repo-workflow`, `bdk-cli-reviewers`), read it first; it records repo-specific traps and what each reviewer checks.

## AI policy check (do this first, every repo)

Look for `AI_POLICY.md`, an "AI" section in `CONTRIBUTING.md`, or `doc/AI_POLICY.md` (Bitcoin Core). Many Bitcoin projects (Bitcoin Core, and BDK is moving the same way) require that:
- comments, issue text, PR bodies and replies to reviewers are written by the human, in their own words;
- the human can explain and defend every line of the change;
- PRs are not opened or driven by agents, and agents are never commit authors or co-authors.

When such a policy exists (or the org clearly follows one), do NOT hand over paste-ready maintainer-facing text. Instead provide: the verified facts with file:line references, the key points to make, questions worth asking, and a review of the user's own draft for technical accuracy. Code help is fine; the user must understand it well enough to explain it unaided. When no policy exists, still recommend the user rewrite drafts in their own voice.

## Issue types: pick the right role

- **bug**: reproduce, claim, fix (Phases 1-12).
- **discussion / design / RFC / ideation**: you are a discussion participant, not an implementer. Don't claim it or say "I'll work on this". Contribute feasibility analysis grounded in code, a concrete API sketch, trade-offs, and sharp questions. Implementation only after a design is agreed and a maintainer says so.
- **PR review request**: build, test by hand, check every branch, then Concept ACK / tACK `<hash>` with what you tested.

---

## Phase 1 - Triage the issue

1. Read the issue, then read the actual code it references. Issues are often wrong in details (flag names, file paths, proposed code).
2. **Reproduce on upstream `master`** with the real binary. Save the output; it becomes evidence for the PR ("before" column).
3. Check the issue's proposed fix against the real types. Open the dependency source in `~/.cargo/registry/src/*/<crate>-<version>/` and confirm derives/traits (e.g. a library enum with no `Clone` cannot be a clap field).
4. Check for existing PRs/issues: `gh issue list --search ...`, `gh pr list --search ... --state all`.
5. Assess the stakes for users: does the bug produce wrong keys, wrong amounts, lost funds, leaked secrets, a panic, or silent coercion? Silent wrong behavior is worse than a crash.
6. Identify compatibility surface: CLI flag names, short flags, env vars, defaults, JSON output fields, config files. These must not change unless that is the point of the fix.

## Phase 2 - Claim the issue

Comment before writing a PR, and wait for a maintainer ack/assignment on non-trivial work. Keep it short, correct the issue's factual errors politely, state the approach.

```markdown
Hi, I'd like to work on this.

Small note: the flag is `--entropy` / `-e` (env `WORD_COUNT`), not `--word-count`.

Plan:
- <one line per change>
- Keep <flag/env/default> unchanged
- Add tests for <valid cases> and <rejected cases>
- Add a CHANGELOG note, since <old behavior> will now <new behavior>

Happy to adjust if you'd prefer a different approach.
```

If the plan changes after investigation (e.g. the proposed type doesn't work), say so in the PR's notes to reviewers.

## Phase 3 - Plan the change

- Do exactly what the issue/reviewer asks. When the change forces extra edits, list them separately as "needed as a consequence" vs "judgment call" so the user can choose.
- Follow existing patterns in the codebase before inventing one. Find the precedent (`grep` for a similar enum, helper, or test) and cite it in the PR.
- Respect layering: thin handlers/commands, logic in utils/lib modules; lower layers never import from higher ones.
- Prefer validating at the boundary (clap `ValueEnum` / `value_parser`, `FromStr`) so bad input fails at parse time with the valid options listed.
- Call out every user-visible behavior change explicitly; it goes in the CHANGELOG and PR.

## Phase 4 - Branch hygiene

```bash
git remote -v                      # origin = fork, upstream = project
git fetch upstream
git switch -c <type>/<short-topic> upstream/master
```

- Never branch from `origin/master` without checking it matches `upstream/master`; forks go stale.
- One branch per PR. Don't stack unrelated work.
- Don't touch other in-progress branches or unrelated stashes.

## Phase 5 - Implement (Bitcoin safety rules)

- Never weaken validation to make something pass. Never accept placeholder/unchecked keys by default.
- Return errors, never panic, on any user input. Watch for library calls that panic on "impossible" states (e.g. miniscript compiling a key invalid for the script context); validate first.
- Never log or print secrets (xprv, mnemonic, passwords) beyond what the command is meant to output.
- Reference the relevant BIP (BIP32/39/341/389...) for behavior; match it exactly.
- Mind feature gates (`#[cfg(feature = "...")]`): imports used only under a feature must be gated the same way, or clippy fails in the other configuration.
- Doc comments go above attributes and `#[cfg]` lines.
- Keep diffs minimal: no drive-by refactors, renames, or formatting of untouched code.

## Phase 6 - Prove it works

Run all of these and report actual numbers, not "should pass":

1. **Tests reproduce the bug:** temporarily restore the old implementation (`git show HEAD:<file> > <file>`, keep a copy of the fix in the scratchpad), run the new tests, confirm they FAIL; restore the fix, confirm they PASS.
2. **Cover every branch:** each accepted value and each rejection path has a test. Reviewers will look for the untested `Err` arm.
3. **Round-trip checks** where relevant (generate then restore yields the same key; compile then parse the descriptor).
4. **Manual before/after table** using the real binary, including env-var paths and defaults.
5. **Feature matrix:** `cargo fmt --check`; `cargo clippy --all-targets` with default features, with each relevant feature, and `--no-default-features`; tests with the features that enable the code. Check the test count; "0 passed" means the feature wasn't enabled.
6. If something can't run locally (missing system lib), say so plainly and let CI cover it.

## Phase 7 - Commits and CHANGELOG

- Signed (`git commit -S`), single-line conventional message: `fix(scope): ...`, `refactor(scope): ...`, `test: ...`, `docs: ...`.
- Logical commits only. Maintainers commonly ask to squash to 1-2 commits. No merge commits ever; update via rebase.
- CHANGELOG: add one line at the end of the Unreleased section in the file's existing voice (`Fixed ...`, `Added ...`). State user-visible behavior changes, including newly rejected inputs.
- Before pushing: `git log --format='%h %G? %s' upstream/master..HEAD` (all `G`), `git show --stat` each commit, `git status` clean.

## Phase 8 - PR description

Use the repo's `.github/pull_request_template.md` headings and checklist wording. Output as raw markdown in a fenced block. Keep it under ~40 lines.

```markdown
### Description

<what was wrong on master, one or two sentences>

<what it does now, one or two sentences>

Fixes #<n>

| Input | Before | After |
|---|---|---|
| ... | ... | ... |

### Notes to the reviewers

- <why this design; cite the codebase precedent>
- <behavior change, noted in CHANGELOG>

### Checklists
<template checklist, ticked honestly>
```

Then comment on the issue linking the PR. Keep the description accurate after every review round; stale descriptions (renamed flags, removed helpers) get flagged.

## Phase 9 - Review rounds

Bitcoin review vocabulary:
- **Concept ACK**: agrees with the idea, not the code yet.
- **Approach ACK**: agrees with the design.
- **ACK <hash>** / **tACK** (tested ACK): approves that exact commit. New pushes reset it.
- **NACK**: objects; needs discussion, not just code.
- **nit**: minor, non-blocking; still address it or say why not.

Handling a round:
1. Reproduce any reported bug exactly before replying. Confirm root cause.
2. Verify every claim you'll make. If asked "was this broken on master?", run master and answer with evidence. Don't write CHANGELOG lines describing regressions your own branch introduced.
3. Reply on each inline thread with a short "Done, <what>" or a reasoned disagreement. Resolve the thread after replying (or leave it for the reviewer if the project prefers).
4. Post one summary comment, then re-request review.
5. Before re-requesting, self-review: is the PR description still accurate? Are comments/doc strings in tests still true? Is every new error branch tested?

Reply template:

```markdown
Thanks @<reviewer>. Addressed:

- <change 1>
- <change 2>

Rebased on latest master; history is still <n> commits.
```

## Phase 10 - Rebases and conflicts

- Never use GitHub's "Resolve conflicts" button; it creates a merge commit. Rebase locally on `upstream/master`.
- Never use GitHub's "Update branch" button either. It adds a `Merge branch 'master' into ...` commit, and its automatic conflict resolution can silently drop lines (on bdk-cli #366 it deleted 4 upstream CHANGELOG entries). "Update with rebase" avoids the merge commit but still can't be verified or signed before pushing. Update locally: `git fetch upstream && git rebase upstream/master`, check `git diff upstream/master --stat` (CHANGELOG should show only your added lines, no deletions), then `git push --force-with-lease`.
- If the remote branch already has merge commits, rebuild from a clean local commit (or `git rebase upstream/master` and drop the merges), then force-push with lease.
- CHANGELOG append conflicts are routine: keep upstream's lines, add yours last. Rebuild from `git show upstream/master:CHANGELOG.md` plus your lines instead of hand-editing nested markers.
- **Fixup target:** before `git commit --fixup <c>`, run `git log --oneline -- <file>`. If a later commit also edits those lines, fold into the later commit (`git commit --amend`) instead, or the autosquash will conflict.
- After every rebase, check each commit, not just HEAD, for leftover markers:
  `for c in $(git rev-list upstream/master..HEAD); do git show $c:<file> | grep -c '^<<<<<<<\|^>>>>>>>'; done`
- Use `git range-diff` to confirm only intended changes moved.
- Push rewritten history with `git push --force-with-lease origin <branch>` only (and only when the user asks). Never force-push shared branches.
- If a rebase goes wrong: `git rebase --abort` restores the pre-rebase state. Don't start a second rebase while one is in progress.

## Phase 11 - CI

- Read the failing test and where it failed. If it fails in environment setup (node/electrum/network, "connection reset", timeouts) before project code runs, and unrelated tests using the same setup pass, it's a flake: re-run failed jobs (`gh run rerun <id> --failed`).
- If it fails twice the same way, mention it on the PR as unrelated, with the error line.
- Real failures in your area: reproduce locally with the same feature flags as CI.

## Phase 12 - After merge

- Check whether the maintainer applied your remaining nits before merge (`git log upstream/master`); don't open a duplicate follow-up.
- Thank reviewers briefly on unresolved nit threads.
- Delete merged local branches; rebase other open branches on the new `upstream/master`.

---

## Pre-review checklist (run before every "ready for review")

- [ ] Bug reproduced on upstream master, output saved
- [ ] Issue/reviewer claims verified against real code and types
- [ ] Only requested changes; extras labeled and approved
- [ ] Flags, env vars, defaults, output formats unchanged unless intended
- [ ] No panics on user input; no weakened validation; no secrets logged
- [ ] New tests fail on old code and pass on new; every error branch tested
- [ ] fmt, clippy (each feature config), tests with right features; counts checked
- [ ] CHANGELOG line added at end of Unreleased; nothing else in it touched
- [ ] Commits signed, conventional, squashed, no merge commits, no markers in any commit
- [ ] Branch based on fresh `upstream/master`, updated by local rebase (never GitHub "Update branch")
- [ ] `git diff upstream/master --stat` shows only intended files; CHANGELOG has no deleted lines
- [ ] PR description matches the current code; test comments accurate
- [ ] No AI attribution in commits, PR text, or comments
- [ ] AI policy checked; maintainer-facing text written by the user in their own words
