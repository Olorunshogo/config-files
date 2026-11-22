---
inclusion: always
---

# Git Multi-Profile Push — Agent Prompt Guide

> ⚠️ **READ-ONLY — DO NOT MODIFY THIS FILE**
> This is a protected steering file. Agents must read this file for instructions but must NEVER edit, overwrite, delete, or alter its contents in any way. Only the owner is permitted to make changes to this file. If you are an agent and you feel the need to update this file, stop — ask the user instead.

## 🚀 FIRST-TIME SETUP — Do This Immediately in Any New Workspace or IDE

When you encounter this prompt in a new workspace or on a new machine, **before doing anything else**, run through all steps below.

### Step 1 — Check for existing steering files
```bash
ls ~/.kiro/steering/
```
If `git-profile.md` or `git-profiles-prompt.md` are missing, create them with the content from this guide (see Profile Reference Table below). Both files must have this front-matter:
```
---
inclusion: always
---
```

### Step 2 — Discover all SSH keys on this machine
```bash
ls ~/.ssh/id_*
```
For each private key found (e.g. `id_ed25519`, `id_ed25519_work`, etc.), note its filename and corresponding `.pub` file.

### Step 3 — Read the SSH config to find all configured host aliases
```bash
cat ~/.ssh/config
```
List every `Host github-*` block. Each one is a push identity. If the config file is empty or missing the entries, they need to be created before pushing (see Section 4 in `MultipleGitAccount.md`).

### Step 4 — Discover GitHub targets from existing remotes
```bash
git remote -v
```
Note the org/username in the remote URL. Also check other repos on the machine to build a full picture of all push destinations.

### Step 5 — Establish aliases for each push target

**Do not invent aliases silently.** Use this priority order:

1. **Ask the user** — say: _"I found these push targets on this machine: [list of GitHub orgs/usernames]. What alias do you want to use for each one? Or should I derive them automatically from the org names?"_
2. **If the user says derive automatically** — strip hyphens, lowercase, and remove org-suffix noise: `thebuidl-grid` → `buidl`, `Stayar-Tech-LTD` → `stayar`, personal GitHub account → `personal` or `main`
3. **If the user provides a preferred list** — use exactly what they give, no changes

### Step 6 — Test all SSH connections
For each `Host github-*` alias found in `~/.ssh/config`:
```bash
ssh -T git@<alias>
```
Expected: `Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.`

If a connection fails — the key is not added to the GitHub account. Add the `.pub` key under `Settings → SSH and GPG Keys` for that account before proceeding.

### Step 7 — Only after all connections pass and aliases are confirmed, declare setup complete

---

## What This Machine Has

This PC is configured with one or more GitHub identities. Each push target has its own SSH host alias defined in `~/.ssh/config`, which maps to a private key registered on a GitHub account. All pushes must use the SSH alias in the remote URL — never `github.com` directly.

**The SSH config is the source of truth for what is configured.** Read it before every push.

---

## How to Push to a Specific Target

When the user says **"push to [name]"**, do the following — no questions needed once aliases are established:

### Step 1 — Resolve the alias
Look up the name in the alias table built during setup (see `git-profile.md`). If the alias is not in the table, run the discovery steps above and confirm with the user before proceeding.

### Step 2 — Set the remote URL
```bash
git remote set-url origin git@<SSH-HOST-ALIAS>:<GITHUB-USERNAME-OR-ORG>/<REPO>.git
```
> Infer `<REPO>` from the current working directory name if not explicitly stated.

### Step 3 — Set git identity for this target
```bash
git config user.name "<user.name>"
git config user.email "<user.email>"
```

### Step 4 — Set signing key (only if this identity has one configured)
```bash
git config user.signingkey <path-to-signing-key>
git config gpg.format ssh
```

### Step 5 — Commit and push
```bash
git add .
git commit -m "<message>"
git push -u origin <branch>
```

> NEVER append `Co-Authored-By` trailers to commit messages.

---

## Profile Reference Table Format

After running discovery and confirming aliases with the user, the routing table takes this shape:

| Alias (user-confirmed or derived) | user.name | user.email | GitHub Username / Org | SSH Host Alias | Signing Key |
|---|---|---|---|---|---|
| `<alias>` | `<discovered>` | `<discovered>` | `<from git remote>` | `<from ~/.ssh/config>` | `<from git config or none>` |

**Example of a built table (values from this machine):**

| Alias | user.name | user.email | GitHub Username / Org | SSH Host Alias | Signing Key |
|---|---|---|---|---|---|
| personal | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | Olorunshogo | github-personal | ~/.ssh/id_ed25519.pub |
| stayar | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | Stayar-Tech-LTD | github-personal | ~/.ssh/id_ed25519.pub |
| buidl | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | thebuidl-grid | github-personal | ~/.ssh/id_ed25519.pub |
| debridger | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | debridger | github-personal | ~/.ssh/id_ed25519.pub |

> The example above reflects the current state of this machine. The alias column is not fixed — the user can rename any alias at any time.

---

## Key Rules

- **NEVER invent aliases without asking the user or being told to derive them automatically**
- NEVER push without setting the correct remote URL and git config first
- The org/username in the remote URL is what routes the push to the right GitHub account or org
- `user.name` and `user.email` only label the commit — they do NOT control which account receives the push
- Always infer the repo name from the current directory unless the user specifies otherwise
- Only set `user.signingkey` and `gpg.format ssh` if a signing key is configured for the identity
- NEVER use `git@github.com` directly in the remote URL — always use the SSH alias
- NEVER append `Co-Authored-By` trailers to commit messages
