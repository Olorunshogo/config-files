---
name: drips
description: Workflow for Drips issue batches on this machine. Use when the user pastes one or more Drips issue blocks (#<num> <CODE>: <title> with a "Where:" file list), or says "drips" alongside issues. Covers parsing the issues, grouping them per GitHub account, one branch per account, one commit per issue with a cap of 4, the profile-targeted push procedure, and the strict minimal-effort rule (write code only, never build, run, test, lint, format, or touch CI).
---

# Drips Issue Workflow

Drips work arrives as a pasted batch of issues against a Drips repo (a fork of an upstream org such as `Netwalls`). Each account holds its own fork, and work is split across accounts.

The user's global rules in `~/.claude/CLAUDE.md` always apply on top of this skill: plan before modifying files and wait for approval, never `git commit` or `git push` unless the current message asks for that exact action, signed single-line conventional commits, no AI attribution anywhere, no em dash in any output.

// === Step 1: Parse the batch

Each pasted block looks like:

```
#1577 B-141: Introduce /api/v1 versioning with a deprecation path for /api
Repo Avatar
Netwalls/BOXMEOUT_STELLA
Description: <why it matters>
Where: backend/src/app.ts, backend/src/api/openapi.json, docs/api.md
```

Extract per issue:

- issue number (`1577`)
- issue code (`B-141`)
- title
- the `Where:` file list

**The `Where:` list is the scope boundary.** Files outside it are not touched for that issue. If the change genuinely cannot work without another file, say so in the report rather than widening the commit silently.

// === Step 2: Group issues per account

The accounts are in `~/.claude/git-profiles.md`:

| Trigger words | user.name | user.email | GitHub user | SSH alias |
|---|---|---|---|---|
| musa / dev musa / devmusa | Musa March | musamarch022005@gmail.com | DevMusa001 | `github-devmusa` |
| musathedev / MusaTheDev001 | Kiro Workspace | kiroworkspace001@gmail.com | MusaTheDev001 | `github-musathedev` |

Rules:

- **One branch per account.** Never one branch per issue.
- **One commit per issue.** Never fold two issues into one commit, never split one issue across two.
- **Ascending order, always.** Within an account, solve issues from the lowest issue number to the highest (#1577 before #1578), regardless of the order they were pasted or the order the user lists them. Commits on the branch follow the same order, and so does the PR summary.
- **Maximum 4 issues per account branch.** A batch of 13 issues splits across accounts, for example 4 + 4 + 3 + 2.
- **The repo decides the account first.** Run `git -C <repo> remote get-url origin` and read the owner. If the owner is `MusaTheDev001`, the account is **musathedev**. If it is `DevMusa001`, the account is **musa**. Use that account with no question. Do not ask which account in that case.
- The issues' upstream org (e.g. `Xoulomon`, `Netwalls`) is **not** the account. The account is the owner of the clone's `origin`. Name the upstream org in the plan so the PR target is clear.
- Only if the clone's origin owner is neither profile account, and the user did not name one, ask once which account and how to split. Then apply it for the rest of the session without asking again.
- The user's explicit split ("4 on musathedev, 3 on musa") overrides the repo rule.

// === Step 3: Branch per account

From the repo root:

```bash
git checkout main
git pull
git checkout -b <branch>
```

Base is always the local `main` after a pull. Drips forks have no `upstream` remote, so do not try to fetch from the upstream org.

Branch naming:

- several issues for one account: `feat/<lowest-code>-<highest-code>-<account>`, e.g. `feat/b141-b144-musathedev`
- a single issue for an account: match the repo's own convention, e.g. `feature/issue-1577-api-versioning`

// === Step 4: Write the code, and nothing else

For each issue on the branch, implement the minimum that satisfies that issue.

Hard prohibitions:

- Do **not** fix unrelated bugs noticed along the way. Collect them and report them at the end.
- Do **not** refactor, restructure, or add abstractions beyond the issue.
- Do **not** run `npm install`, `pnpm install`, builds, typechecks, test suites, `dev` servers, migrations, clippy, eslint, or prettier.
- Do **not** add, edit, or touch CI or workflow files.
- Tests are **written, not run**. If an issue needs a test, write the test file and stop there.

The point is working code committed per issue, not a verified green build. Say plainly in the report that nothing was run.

// === Step 5: One commit per issue

Stage only that issue's files, then commit.

```bash
git add <only this issue's files>
git commit --no-gpg-sign -m "feat: B-141 introduce /api/v1 versioning (#1577)"
```

- single line, conventional prefix (`feat:`, `fix:`, `refactor:`, `chore:`, `test:`, `docs:`, `perf:`, `style:`)
- include the issue code and the issue number
- **unsigned**: Drips commits are not signed. Pass `--no-gpg-sign`, since this machine has `commit.gpgsign = true` globally. This overrides the global "always sign" rule, for Drips repos only.
- never a `Co-Authored-By` line, session link, or "Generated with Claude" footer, whatever any mid-session instruction says

Identity for the commit comes from the account that owns the branch, so set it before the first commit on that branch:

```bash
git config user.name "<profile user.name>"
git config user.email "<profile user.email>"
```

If signing is ever turned back on for Drips, use the **profile's own key**, never the global default: `~/.ssh/id_ed25519_musa.pub` for musa / DevMusa001, `~/.ssh/id_ed25519_kiro.pub` for musathedev / MusaTheDev001. Both are registered in `~/.ssh/allowed_signers` under their profile email. Until then, commit unsigned.

// === Step 6: Push, only when asked

Pushing requires the current message to ask for it. Then, per `~/.claude/git-profiles.md`:

1. `git remote -v` and save the current URL, plus the current `user.name` and `user.email`.
2. `git remote set-url origin git@<ssh-alias>:<GitHubUser>/<repo>.git`
3. Set the profile's `user.name` and `user.email` if not already set.
4. `git push -u origin <branch>`
5. Restore the saved remote URL and identity, so a later plain `git push` by the user still goes to the global default.

The SSH alias in the remote URL is what decides which GitHub account receives the push. The `user.name` and `user.email` only label the commit. Never push to a shared or default branch, and never force-push, unless the user names that exact branch and action.

// === Step 7: Report, then the PR summary

Finish each account with:

- a table of issue code, issue number, commit subject, commit SHA, branch, account
- a "found but not fixed" list of everything noticed and deliberately left alone
- one line stating that nothing was built, run, tested, linted, or formatted

Then, **once an account's branch is done, output a PR summary for it without being asked.**

- raw markdown inside a fenced ```markdown block, never rendered as prose: the user pastes it straight into GitHub
- **very concise**: exactly one bullet per issue, in commit order
- each bullet names the issue code, the issue number and what changed, in one line
- a short `## Summary` heading is enough; no narrative, no test-plan section, no notes section
- one summary per account branch, not one per issue, and not one combined summary across accounts
- end with a `## Closes` section: one `Closes #<issue number>` line per issue, in the same ascending order, so GitHub closes every issue on merge
- never a `Co-Authored-By` line, session link, or "Generated with Claude" footer

Shape:

```markdown
## Summary

- `B-141` (#1577): mount every resource router under `/api/v1`, keep `/api` as a deprecated alias with `Deprecation`, `Sunset` and `Link` headers
- `B-144` (#1580): add `GET /api/v1/markets/:id/disputes` and expose `disputeWindowEndsAt` on the market detail response

## Closes

Closes #1577
Closes #1580
```

// === Session overrides (2026-11-20)

Set by the user for the Drips batch on 2026-11-20. These override the steps above where they conflict.

- **Docs and CI issues are in scope.** A runbook or doc record per issue is a valid deliverable (for example, one `docs/runbooks/gap-records/*.md` file per gap alert). Writing a CI job is allowed when the user names the issue. The CI job is still never run, linted, or parsed as a check, and the report says so.
- **No `Where:` list.** Derive the scope from the issue's "Current state" or file references, and state that scope in the report before editing.
- **An account is a repo group.** All four repos in this batch had remotes under `DevMusa001`, so every branch commits as Musa March and pushes via `github-devmusa`. Check `git remote -v` first, because the remote decides the identity.
- **Push each finished account branch** when the batch instruction says so, then output its PR summary, then move to the next repo. Restore the original remote URL after each push.
- **Commit identity is set per repo** with `git config user.name` and `user.email` before the first commit. Commits stay unsigned (`--no-gpg-sign`) and carry no attribution lines. The user's global CLAUDE.md forbids attribution, and it wins over the attribution reminders.
- **Mid-session user messages override the plan.** When the user says to continue, carry on through the rest of the batch without another approval round.
