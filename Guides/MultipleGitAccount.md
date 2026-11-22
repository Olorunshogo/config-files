# Multiple GitHub Accounts — Complete Setup & Usage Guide

This document contains everything needed for any LLM (or human) to understand, set up, and operate a multi-target GitHub push workflow on this machine. Read every section before taking any action.

---

## 1. The Core Concept (Read This First)

Git does NOT choose which GitHub account or org to push to based on `user.name` or `user.email`. Those fields only label the commit author — they are cosmetic.

The actual GitHub account or org used when pushing is determined by:
1. The **remote URL** — specifically the SSH host alias and the org/username in it
2. The **SSH config** — which maps that alias to a specific private key
3. The **SSH key** — which is registered to a specific GitHub account

So the correct mental model is:

```
Remote URL  →  selects which SSH alias + which GitHub org/username
SSH alias   →  maps to a specific private key (~/.ssh/config)
Private key →  is registered on a specific GitHub account
GitHub      →  authenticates and accepts the push as that account/org
git config  →  only labels who authored the commit (name/email)
```

This means:
- Changing `git config user.name` alone does NOT switch accounts or orgs
- You MUST change the org/username in the remote URL to push to the right destination
- You MUST also set `user.name` and `user.email` so commits are labeled correctly
- **Push target aliases are not fixed** — they are established by asking the user or derived from org names

---

## 2. How Push Target Aliases Are Established

Aliases are the shorthand names a user says when they want to push (e.g. "push to stayar", "push to personal"). They are **not hardcoded in this document**. Instead, an LLM must discover the available targets and establish aliases using this protocol:

### Discovery Protocol

**Step 1 — List all SSH keys:**
```bash
ls ~/.ssh/id_*
```

**Step 2 — Read the SSH config to find all host aliases:**
```bash
cat ~/.ssh/config
```
Every `Host github-*` block is a configured push identity.

**Step 3 — Check git remotes to find GitHub targets:**
```bash
git remote -v
```
The org/username in the remote URL is the GitHub destination.

**Step 4 — Read the git identity:**
```bash
git config user.name
git config user.email
git config user.signingkey
```

**Step 5 — Establish aliases:**

Do not silently invent aliases. Use this priority order:
1. **Ask the user** — _"I found these push targets: [list]. What alias do you want for each? Or should I derive them from the org names?"_
2. **Auto-derive if told to** — lowercase the org name, strip hyphens and suffixes: `thebuidl-grid` → `buidl`, `Stayar-Tech-LTD` → `stayar`, personal GitHub account → `personal`
3. **Use the user's list exactly** if they provide one

---

## 3. The Push Targets on This Machine

This machine uses one GitHub identity across a personal account and multiple organization accounts. Below is the current push target table — **the alias column reflects what the user has confirmed, not hardcoded values**.

| Alias | Git user.name | Git user.email | SSH Host Alias | GitHub Username / Org |
|---|---|---|---|---|
| personal | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | github-personal | Olorunshogo |
| stayar | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | github-personal | Stayar-Tech-LTD |
| buidl | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | github-personal | thebuidl-grid |
| debridger | Olorunshogo Moses BAMTEFA | shownzy001@gmail.com | github-personal | debridger |

> If the user renames an alias or adds a new target, update this table accordingly.

---

## 4. SSH Keys on This Machine

| Identity | Private Key File | Public Key File |
|---|---|---|
| personal (all targets) | ~/.ssh/id_ed25519 | ~/.ssh/id_ed25519.pub |

The public key is registered on the `Olorunshogo` GitHub account under:
`Settings → SSH and GPG Keys`

This key is also configured as the commit signing key:
```
user.signingkey = ~/.ssh/id_ed25519.pub
gpg.format = ssh
commit.gpgsign = true
```

---

## 5. SSH Config (~/.ssh/config)

This file maps SSH host aliases to private keys. It must contain an entry for every push identity. Read it before every push to confirm aliases exist.

**Current required entry:**
```
# Personal + Org pushes (single identity)
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
```

To view or edit: `nano ~/.ssh/config`

If an entry is missing, add it:
```bash
cat >> ~/.ssh/config << 'EOF'

# Personal + Org pushes (single identity)
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
EOF
chmod 600 ~/.ssh/config
```

---

## 6. How to Test Each SSH Connection

For each `Host` alias in `~/.ssh/config`, test the connection:
```bash
ssh -T git@<alias>
```

Expected output:
```
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

Each alias should respond with the correct GitHub username. If it fails, add the `.pub` key to that GitHub account under `Settings → SSH and GPG Keys`.

---

## 7. Remote URL Format

The remote URL MUST use the SSH host alias — NOT `github.com` directly.

**Wrong (uses default system key, may route incorrectly):**
```
git@github.com:Olorunshogo/repo.git
git@github.com:Stayar-Tech-LTD/repo.git
```

**Correct (alias controls authentication, org controls destination):**
```
git@github-personal:Olorunshogo/repo.git
git@github-personal:Stayar-Tech-LTD/repo.git
git@github-personal:thebuidl-grid/repo.git
git@github-personal:debridger/repo.git
```

---

## 8. Per-Target Command Template

For each push target, use this template. Substitute values from the alias table (Section 3):

```bash
git remote set-url origin git@<SSH-HOST-ALIAS>:<GITHUB-ORG-OR-USERNAME>/<repo>.git
git config user.name "<user.name>"
git config user.email "<user.email>"
# only if a signing key is configured:
git config user.signingkey <path-to-signing-key>
git config gpg.format ssh
```

**Current machine — filled examples:**

### personal / main
```bash
git remote set-url origin git@github-personal:Olorunshogo/<repo>.git
git config user.name "Olorunshogo Moses BAMTEFA"
git config user.email "shownzy001@gmail.com"
git config user.signingkey ~/.ssh/id_ed25519.pub
git config gpg.format ssh
```

### stayar
```bash
git remote set-url origin git@github-personal:Stayar-Tech-LTD/<repo>.git
git config user.name "Olorunshogo Moses BAMTEFA"
git config user.email "shownzy001@gmail.com"
git config user.signingkey ~/.ssh/id_ed25519.pub
git config gpg.format ssh
```

### buidl
```bash
git remote set-url origin git@github-personal:thebuidl-grid/<repo>.git
git config user.name "Olorunshogo Moses BAMTEFA"
git config user.email "shownzy001@gmail.com"
git config user.signingkey ~/.ssh/id_ed25519.pub
git config gpg.format ssh
```

### debridger
```bash
git remote set-url origin git@github-personal:debridger/<repo>.git
git config user.name "Olorunshogo Moses BAMTEFA"
git config user.email "shownzy001@gmail.com"
git config user.signingkey ~/.ssh/id_ed25519.pub
git config gpg.format ssh
```

Replace `<repo>` with the actual repository name (infer from the current directory if not stated).

---

## 9. The Mandatory Pre-Push Checklist

Before EVERY commit and push, an LLM or operator MUST do the following steps in order:

1. **Resolve the alias** from the target table (Section 3) — if unknown, run discovery (Section 2) and ask the user

2. **Check current remote:**
   ```bash
   git remote -v
   ```

3. **Set remote URL** to the correct SSH alias and org/username (see Section 8)

4. **Set git config user.name** for the target

5. **Set git config user.email** for the target

6. **Set signing key** (if configured):
   ```bash
   git config user.signingkey <path>
   git config gpg.format ssh
   ```

7. **Stage changes:**
   ```bash
   git add .
   ```

8. **Commit** (no `Co-Authored-By` trailer):
   ```bash
   git commit -m "your message"
   ```

9. **Push:**
   ```bash
   git push -u origin <branch-name>
   ```

Never skip steps 1–6. Never push using `github.com` directly in the remote URL.

---

## 10. Cloning a Repo for a Specific Target

When cloning a new repo, use the SSH alias in the URL from the start:

```bash
git clone git@<SSH-HOST-ALIAS>:<GITHUB-ORG-OR-USERNAME>/<repo>.git
```

Then immediately set the local git config:
```bash
cd <repo>
git config user.name "<user.name>"
git config user.email "<user.email>"
git config user.signingkey <path-to-signing-key>
git config gpg.format ssh
```

---

## 11. Fixing the Remote on an Existing Repo

If a repo was cloned with the wrong URL or needs to switch target:

```bash
# Check what it currently is
git remote -v

# Update it
git remote set-url origin git@<SSH-HOST-ALIAS>:<username-or-org>/<repo>.git
```

---

## 12. Full Workflow Example — Stash, Branch, Pop, Commit, Push

```bash
# 1. Stash all current changes including untracked files
git stash -u -m "work in progress"

# 2. Create and switch to a new branch (choose a descriptive name)
git checkout -b feat/<descriptive-branch-name>

# 3. Restore stashed changes onto the new branch
git stash pop

# 4. Resolve alias → get SSH alias and GitHub org from the target table

# 5. Set remote URL
git remote set-url origin git@<SSH-HOST-ALIAS>:<GITHUB-ORG>/<repo>.git

# 6. Set git identity
git config user.name "<user.name>"
git config user.email "<user.email>"
git config user.signingkey <path-to-signing-key>
git config gpg.format ssh

# 7. Stage, commit, and push
git add .
git commit -m "your descriptive commit message"
git push -u origin feat/<descriptive-branch-name>
```

---

## 13. How to Verify Everything Is Correct Before Pushing

```bash
# Read SSH config to confirm aliases are present
cat ~/.ssh/config

# Confirm remote URL has the right SSH alias and org
git remote -v

# Confirm git identity is set correctly
git config user.name
git config user.email

# Confirm you are on the right branch
git branch

# Test SSH connection for the target alias
ssh -T git@<alias>
```

---

## 14. Setting Up From Scratch (If Key Is Lost or New Machine)

### Step 1 — Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "<your-email>" -f ~/.ssh/id_ed25519 -N ""
```

### Step 2 — Add Key to SSH Agent
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Step 3 — Copy the Public Key
```bash
cat ~/.ssh/id_ed25519.pub
```

### Step 4 — Add Public Key to GitHub
1. Log into the GitHub account
2. Go to: `Settings → SSH and GPG Keys → New SSH Key`
3. Paste the public key
4. Name it something identifiable (e.g. `linux-laptop`)

### Step 5 — Write the SSH Config
Add the host alias block (see Section 5). Save and exit.

### Step 6 — Test the Connection
```bash
ssh -T git@<alias>
```
Expected: `Hi <username>! You've successfully authenticated...`

### Step 7 — Run Discovery and Establish Aliases
Follow the Discovery Protocol in Section 2. Ask the user for alias preferences before proceeding.

---

## 15. Common Mistakes to Avoid

| Mistake | Why It's Wrong |
|---|---|
| Inventing aliases without asking the user | Alias names are the user's choice — always confirm or ask to derive |
| Using `git@github.com:...` in remote URL | Bypasses the alias; uses default system key which may not be configured correctly |
| Only changing `git config user.name/email` | Does NOT switch GitHub accounts or orgs, only labels the commit |
| Forgetting to run `git remote set-url` | Push goes to the wrong org or fails authentication |
| Not reading `~/.ssh/config` before pushing | You may be missing the alias and not know it until the push fails |
| Not testing with `ssh -T` after setup | You won't know if the key is linked correctly |
| Using `git config --global` mid-project | Changes identity globally, breaks other repos |
| Cloning with `github.com` instead of alias | Repo is linked to default key from the start |
| Appending `Co-Authored-By` to commits | Not wanted — never add this trailer |

---

## 16. Instructions for Any LLM Given This Document

If you are an LLM reading this document, follow these rules for every commit and push operation:

1. **First session on this machine:** run the Discovery Protocol (Section 2), ask the user for alias preferences, and build the routing table
2. The user will say something like "push to [alias]" — resolve that alias from the routing table
3. If the alias is not in the table, run discovery again and ask the user to confirm before proceeding
4. Run `cat ~/.ssh/config` to confirm the SSH host alias exists — add it if missing
5. Run `git remote -v` to check the current remote
6. Run `git remote set-url origin git@<SSH-HOST-ALIAS>:<github-username-or-org>/<repo>.git`
7. Set `git config user.name`, `git config user.email`, and signing key from the routing table
8. Infer the repo name from the current working directory if the user has not stated it
9. Then stage, commit with a descriptive message, and push
10. Never use `github.com` directly in the remote URL — always use the SSH alias
11. Never append `Co-Authored-By` trailers to commit messages

---

## 17. Quick Reference Card

```
DISCOVERY COMMANDS:
  ls ~/.ssh/id_*                  → list all SSH keys on this machine
  cat ~/.ssh/config               → list all configured host aliases
  git remote -v                   → find the GitHub org/username for this repo
  git config user.name/email      → find the git identity in use
  ssh -T git@<alias>              → test a connection and confirm which account it maps to

ALIAS PROTOCOL:
  1. Discover targets from SSH config + git remotes
  2. Ask user: "What alias for each target?" — or derive from org name if told to
  3. Build routing table and use it for the session

REMOTE URL FORMAT:
  git@<SSH-HOST-ALIAS>:<github-username-or-org>/<repo>.git

CURRENT MACHINE EXAMPLES:
  git@github-personal:Olorunshogo/myproject.git
  git@github-personal:Stayar-Tech-LTD/Stayar-V2.git
  git@github-personal:thebuidl-grid/thebuidl-web-v2.git
  git@github-personal:debridger/debridgers-monorepo.git
```
