---
inclusion: always
---

# Git Multi-Profile Push Rules

> ⚠️ **READ-ONLY — DO NOT MODIFY THIS FILE**
> This is a protected steering file. Agents must read this file for instructions but must NEVER edit, overwrite, delete, or alter its contents in any way. Only the owner is permitted to make changes to this file. If you are an agent and you feel the need to update this file, stop — ask the user instead.

Before every commit and push, you MUST follow these rules without being asked.

## ⚡ QUICK REFERENCE — Read This First

This machine has one GitHub identity used across a personal account and multiple organization accounts. **Push target aliases are not hardcoded — they are discovered from the SSH config and git remotes, then confirmed with the user or derived automatically.**

**When the user says "push to [name]" — resolve the alias using the steps below, apply ALL settings for that target, then commit and push. No questions needed once aliases are established.**

---

## Step 0 — Discover and Build the Push Target Table (Do This Once Per Session)

Before pushing, run these discovery commands to build the routing table for this machine:

### 1. Read the SSH config to find all configured host aliases
```bash
cat ~/.ssh/config
```
List every `Host github-*` entry. Each entry maps an alias to a private key and represents a usable push identity.

### 2. Read the current git remote to find the GitHub target
```bash
git remote -v
```
Note the org/username in the remote URL. This is the GitHub destination for pushes from this repo.

### 3. Read the git identity configured on this machine
```bash
git config user.name
git config user.email
git config user.signingkey
```

### 4. Establish aliases for each push target

For each GitHub org/username discovered, an alias must be established. Use this priority order:

1. **Ask the user first** — say: _"I found these push targets on this machine: [list]. What alias do you want for each one?"_
2. **If the user says to derive automatically** — use the lowercase org/username, stripping hyphens and suffixes (e.g. `thebuidl-grid` → `buidl`, `Stayar-Tech-LTD` → `stayar`, personal account → `personal` or `main`)
3. **If the user provides a preferred list** — use exactly what they give

Once aliases are confirmed, build the routing table in the format below and use it for the rest of the session.

---

## Push Target Table Format

After discovery, the routing table looks like this:

| Alias (confirmed with user or derived) | user.name | user.email | GitHub Username / Org | SSH Host Alias | Signing Key |
|---|---|---|---|---|---|
| `<alias>` | `<from git config>` | `<from git config>` | `<from git remote>` | `<from ~/.ssh/config>` | `<from git config, or none>` |

**Example of a built table (values are illustrative):**

| Alias | user.name | user.email | GitHub Username / Org | SSH Host Alias | Signing Key |
|---|---|---|---|---|---|
| personal | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | Olorunshogo | github-personal | ~/.ssh/id_ed25519.pub |
| stayar | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | Stayar-Tech-LTD | github-personal | ~/.ssh/id_ed25519.pub |
| buidl | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | thebuidl-grid | github-personal | ~/.ssh/id_ed25519.pub |
| debridger | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | debridger | github-personal | ~/.ssh/id_ed25519.pub |

**Remote URL pattern:** `git@<SSH Host Alias>:<GitHub Username or Org>/<repo>.git`
**Repo name:** always infer from the current working directory if not explicitly stated.

---

## Required Steps Before Every Commit + Push

1. Run `cat ~/.ssh/config` to verify the host alias exists — add it if missing
2. Run `git remote -v` to check the current remote URL
3. Set the remote URL to match the target's SSH alias and GitHub org/username
4. Set `git config user.name` for that target
5. Set `git config user.email` for that target
6. Set `git config user.signingkey` and `git config gpg.format ssh` (if a signing key is configured)
7. Then commit and push

## Remote URL Format

```
git remote set-url origin git@<ssh-alias>:<github-username-or-org>/<repo>.git
```

## Per-Target Command Template

For whichever target the user specifies, run:
```bash
git remote set-url origin git@<SSH-HOST-ALIAS>:<GITHUB-ORG-OR-USERNAME>/<repo>.git
git config user.name "<user.name>"
git config user.email "<user.email>"
# only if a signing key is configured:
git config user.signingkey <path-to-signing-key>
git config gpg.format ssh
```

## Key Rules

- NEVER push without first resolving the alias and setting the correct remote URL and git config
- Git config user.name/email only labels the commit — the org/username in the remote URL is what determines which GitHub account or org receives the push
- Always infer the repo name from the current directory if not explicitly provided
- If the SSH host alias is missing from `~/.ssh/config`, add it before pushing — never use `git@github.com` directly
- If a signing key is configured (`user.signingkey`), always set it and `gpg.format ssh` before committing
- NEVER append `Co-Authored-By` trailers to commit messages
