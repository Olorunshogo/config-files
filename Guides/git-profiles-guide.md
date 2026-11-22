# Multiple Git Accounts on One Machine

How this machine pushes to several GitHub accounts from one user account, and the rules an assistant (or a person) follows before every commit and push. It combines three files:

| Part | File | What it is |
| --- | --- | --- |
| 1 | `~/.claude/git-profiles-prompt.md` | The short instruction given to the assistant |
| 2 | `~/.claude/git-profiles.md` | Quick reference index |
| 3 | `~/.claude/MultipleGitAccounts.md` | Full setup and usage guide |

**The one idea to keep:** `user.name` and `user.email` only label a commit. The SSH host alias in the remote URL decides which GitHub account receives the push.

---

## Part 1: The short prompt

_The instruction an assistant is given on this machine. It points at the two documents below._

This machine has extra GitHub profiles (musa, musathedev) on top of the normal default account. Before any commit/push, check `~/.claude/git-profiles.md` (quick reference) and `~/.claude/MultipleGitAccounts.md` (full guide) for how to handle "push to musa" / "push to dev musa" / "push to musathedev" requests.

**Pre-commit rule:** Before staging or committing anything, establish which profile the commit should be authored as. If the user has not named a profile, ask before committing. Never assume the default profile on a repo that belongs to a musa or musathedev account.

If no profile is named and the repo is the user's normal default repo, change nothing and push normally to the existing default account.

---

## Part 2: Quick reference (`git-profiles.md`)

_The one-page lookup: which name maps to which identity, and the steps for a profile-targeted push._

> READ-ONLY REFERENCE: do not edit unless the user explicitly asks.
> This file is the quick-reference index for `MultipleGitAccounts.md`.

Before every commit and push, follow these rules.

### QUICK REFERENCE: Read This First

This machine has **2 extra GitHub profiles** configured on top of the existing default global profile (untouched, used for normal manual `git push`).

**When the user says "push to [name]": look up the name below, apply ALL settings for that profile, then commit and push. No questions needed.**

| Alias Triggers | user.name | user.email | GitHub Username | SSH Host Alias |
|---|---|---|---|---|
| musa / dev musa / devmusa | Musa March | musamarch022005@gmail.com | DevMusa001 | github-devmusa |
| musathedev / MusaTheDev001 | Kiro Workspace | kiroworkspace001@gmail.com | MusaTheDev001 | github-musathedev |

**Default / unnamed push:** leave remote and git config exactly as they already are on the machine (the global profile). Never switch to musa or musathedev unless the user explicitly names one.

**Remote URL pattern:** `git@<SSH Host Alias>:<GitHub Username>/<repo>.git`
**Repo name:** always infer from the current working directory if not explicitly stated.

---

### Required Steps Before a Profile-Targeted Commit + Push

1. Run `git remote -v` to check the current remote URL.
2. Save the current remote URL and `user.name`/`user.email` (so they can be restored after).
3. Set the remote URL to match the target profile's SSH alias.
4. Set `git config user.name` for that profile.
5. Set `git config user.email` for that profile.
6. Stage, commit, push.
7. Restore the remote URL and git config back to what they were in step 2, so a plain manual `git push` afterward still goes to the global default account.

### Per-Profile Commands

#### Musa (github-devmusa)
```bash
git remote set-url origin git@github-devmusa:DevMusa001/<repo>.git
git config user.name "Musa March"
git config user.email "musamarch022005@gmail.com"
```

#### MusaTheDev (github-musathedev)
```bash
git remote set-url origin git@github-musathedev:MusaTheDev001/<repo>.git
git config user.name "Kiro Workspace"
git config user.email "kiroworkspace001@gmail.com"
```

### Pre-Commit Profile Check (Required)

Before staging or committing anything, the profile to commit as must be established:

1. If the user has named a profile in this session ("push to musathedev", "commit as musa", etc.): use that profile for all commits in this session.
2. If NO profile has been named, ask the user: "Which profile should this commit be authored as: default, musa, or musathedev?" before staging anything.
3. Never assume the default profile for a repo that belongs to another account (e.g. a MusaTheDev001 or DevMusa001 repo).
4. Once a profile is established for a session, apply it consistently to all commits without asking again.

### Key Rules

- NEVER push to musa or musathedev without first setting the correct remote URL and git config for that profile.
- Git config `user.name`/`user.email` only labels the commit: the SSH alias in the remote URL is what determines which GitHub account receives the push.
- After a profile-targeted push, restore the remote URL and git config to the prior (default/global) state so manual pushes by the user are unaffected.
- Always infer the repo name from the current directory if not explicitly provided.
- If the user says "push to musa", "push to dev musa", "push to musathedev", or "push to MusaTheDev001": apply the matching profile above automatically.
- The user's normal/default `git push` (no profile named) must never be redirected: leave the existing global remote and identity exactly as-is.

See `MultipleGitAccounts.md` for full setup details, SSH key locations, and troubleshooting.

---

## Part 3: Full guide (`MultipleGitAccounts.md`)

_How the setup works, every profile's keys and SSH config, testing, setting it up from scratch, and common mistakes._

This document contains everything needed for any LLM (or human) to understand, set up, and operate this machine's multi-GitHub-account workflow. Read every section before taking any action.

---

### 1. The Core Concept (Read This First)

Git does NOT choose which GitHub account to push to based on `user.name` or `user.email`. Those fields only label the commit author: they are cosmetic.

The actual GitHub account used when pushing is determined by:
1. The **remote URL**: specifically the SSH host alias in it
2. The **SSH config**: which maps that alias to a specific private key
3. The **SSH key**: which is registered to a specific GitHub account

So the correct mental model is:

```
Remote URL  ->  selects which SSH alias to use
SSH alias   ->  maps to a specific private key (~/.ssh/config)
Private key ->  is registered on a specific GitHub account
GitHub      ->  authenticates and accepts the push as that account
git config  ->  only labels who authored the commit (name/email)
```

This means:
- Changing `git config user.name` alone does NOT switch accounts.
- You MUST change the remote URL to the correct SSH alias to push to the right account.
- You MUST also set `user.name` and `user.email` so commits are labeled correctly.
- The pre-existing default/global profile on this machine is untouched by any of this. Plain manual `git push` (no profile named) keeps working exactly as it always has.

---

### 2. The Profiles on This Machine

| Profile Alias | Git user.name | Git user.email | SSH Host Alias | GitHub Username |
|---|---|---|---|---|
| (default, unnamed) | unchanged: existing machine default | unchanged | (existing default) | (existing default) |
| musa / dev musa / devmusa | Musa March | musamarch022005@gmail.com | github-devmusa | DevMusa001 |
| musathedev / MusaTheDev001 | Kiro Workspace | kiroworkspace001@gmail.com | github-musathedev | MusaTheDev001 |

---

### 3. SSH Keys on This Machine

Each extra profile has its own SSH key pair stored in `~/.ssh/`:

| Profile | Private Key File | Public Key File |
|---|---|---|
| musa | ~/.ssh/id_ed25519_musa | ~/.ssh/id_ed25519_musa.pub |
| musathedev | ~/.ssh/id_ed25519_kiro | ~/.ssh/id_ed25519_kiro.pub |

Note: the musathedev key file is still named `id_ed25519_kiro` for historical reasons. The `kiro` name is no longer a valid profile trigger: only the filename retains it.

Each public key is registered on its corresponding GitHub account under:
`Settings -> SSH and GPG Keys`

The existing default profile's key (`~/.ssh/id_ed25519`) is unchanged and untouched.

---

### 4. SSH Config (~/.ssh/config)

This file maps each SSH host alias to the correct private key. The extra entries added for this setup:

```
# Musa (DevMusa001)
Host github-devmusa
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_musa

# MusaTheDev (MusaTheDev001)
Host github-musathedev
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_kiro
```

The default/global SSH behavior (whatever key `ssh -T git@github.com` already used before this setup) is untouched: these are additive aliases only.

To view or edit: `nano ~/.ssh/config`

---

### 5. How to Test Each SSH Connection

```bash
ssh -T git@github-devmusa
ssh -T git@github-musathedev
```

Expected output for each:
```
Hi <username>! You've successfully authenticated, but GitHub does not provide shell access.
```

- `github-devmusa` should greet `DevMusa001`.
- `github-musathedev` should greet `MusaTheDev001`.

(Exit code 1 on this command is normal: GitHub closes the shell session after the greeting, it does not indicate failure.)

---

### 6. Remote URL Format

The remote URL must use the SSH host alias, NOT `github.com` directly, when targeting one of the extra profiles.

**Wrong (uses wrong or default account):**
```
git@github.com:username/repo.git
```

**Correct (uses a specific extra profile):**
```
git@github-devmusa:DevMusa001/repo.git
git@github-musathedev:MusaTheDev001/repo.git
```

For the default/global profile, keep using whatever remote URL the repo already has: do not change it unless the user asks to switch profiles.

---

### 7. Per-Profile Remote URL + Git Config Commands

Use these exact commands before committing and pushing to each extra profile.

#### Musa
```bash
git remote set-url origin git@github-devmusa:DevMusa001/<repo>.git
git config user.name "Musa March"
git config user.email "musamarch022005@gmail.com"
```

#### MusaTheDev
```bash
git remote set-url origin git@github-musathedev:MusaTheDev001/<repo>.git
git config user.name "Kiro Workspace"
git config user.email "kiroworkspace001@gmail.com"
```

Replace `<repo>` with the actual repository name (infer from the current directory if not stated).

After the push completes, restore the remote URL and git config to whatever they were before switching, so the user's next manual `git push` goes to their normal default account.

---

### 8. The Mandatory Pre-Commit + Pre-Push Checklist

**Before staging or committing anything**, establish which profile the commit should be authored as:

- If the user has named a profile in this session, use it for all commits in this session.
- If NO profile has been named, ask: "Which profile should this commit be authored as: default, musa, or musathedev?" before staging.
- Never assume the default profile for a repo owned by a musa or musathedev GitHub account.

Before EVERY commit and push targeting an extra profile, an LLM or operator MUST do the following steps in order:

1. **Check current remote and identity, save them:**
   ```bash
   git remote -v
   git config user.name
   git config user.email
   ```

2. **Set remote URL** to the target profile's SSH alias (see Section 7).

3. **Set git config user.name** for the target profile (see Section 7).

4. **Set git config user.email** for the target profile (see Section 7).

5. **Stage changes:**
   ```bash
   git add -A
   ```

6. **Commit:**
   ```bash
   git commit -m "your message"
   ```

7. **Push:**
   ```bash
   git push -u origin <branch-name>
   ```

8. **Restore** the remote URL and git config saved in step 1.

Never skip steps 2, 3, or 4. Never use `github.com` directly in the remote URL when targeting an extra profile.

---

### 9. Cloning a Repo for a Specific Profile

When cloning a new repo specifically for one of the extra profiles, use the SSH alias in the URL from the start:

```bash
# Musa
git clone git@github-devmusa:DevMusa001/<repo>.git

# MusaTheDev
git clone git@github-musathedev:MusaTheDev001/<repo>.git
```

Then immediately set the local git config:
```bash
cd <repo>
git config user.name "<name>"
git config user.email "<email>"
```

For the default/global profile, clone exactly as you always have: no alias needed.

---

### 10. Fixing the Remote on an Existing Repo

If a repo needs to switch from the default profile to an extra profile (or back):

```bash
# Check what it currently is
git remote -v

# Update it to target a specific profile
git remote set-url origin git@github-<alias>:<username>/<repo>.git

# Or restore it to the default/global remote you noted before switching
git remote set-url origin <original-url>
```

---

### 11. How to Verify Everything Is Correct Before Pushing

```bash
# Confirm remote URL has the right SSH alias
git remote -v

# Confirm git identity is set correctly
git config user.name
git config user.email

# Confirm you are on the right branch
git branch

# Test SSH connection for the target profile
ssh -T git@github-devmusa      # or github-musathedev
```

---

### 12. Setting Up From Scratch (If Keys Are Lost or New Machine)

#### Step 1: Generate SSH Keys

```bash
ssh-keygen -t ed25519 -C "musamarch022005@gmail.com" -f ~/.ssh/id_ed25519_musa -N ""
ssh-keygen -t ed25519 -C "kiroworkspace001@gmail.com" -f ~/.ssh/id_ed25519_kiro -N ""
```

A passphrase can be set for extra security; this setup used no passphrase so automated pushes do not prompt.

#### Step 2: Add Keys to SSH Agent (if using one)

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_musa
ssh-add ~/.ssh/id_ed25519_kiro
```

#### Step 3: Copy Each Public Key

```bash
cat ~/.ssh/id_ed25519_musa.pub
cat ~/.ssh/id_ed25519_kiro.pub
```

#### Step 4: Add Each Public Key to the Correct GitHub Account

For each profile:
1. Log into that GitHub account.
2. Go to: `Settings -> SSH and GPG Keys -> New SSH Key`.
3. Paste the public key.
4. Name it something like `laptop-musa`, `laptop-musathedev`.

#### Step 5: Write the SSH Config

```bash
nano ~/.ssh/config
```

Append the two `Host` blocks from Section 4. Save and exit. Do not remove or modify any existing entries already in this file.

#### Step 6: Test All Connections

```bash
ssh -T git@github-devmusa
ssh -T git@github-musathedev
```

Each should respond with `Hi <username>! You've successfully authenticated...`.

---

### 13. Common Mistakes to Avoid

| Mistake | Why It's Wrong |
|---|---|
| Using `git@github.com:...` when targeting an extra profile | Uses the default SSH key, pushes to the wrong account |
| Only changing `git config user.name`/`user.email` | Does NOT switch GitHub accounts, only labels the commit |
| Forgetting to run `git remote set-url` | Push goes to the wrong GitHub account |
| Not testing with `ssh -T` after setup | You won't know if the key is linked correctly |
| Forgetting to restore the remote/identity after a profile-targeted push | The user's next manual `git push` silently goes to the wrong account |
| Cloning with `github.com` instead of the alias when targeting an extra profile | Repo is linked to the wrong account from the start |
| Using the retired `github-musa` or `github-kiro` aliases | Those host aliases no longer exist and SSH will fail to resolve them |

---

### 14. Instructions for Any LLM Given This Document

If you are an LLM reading this document, follow these rules for every commit and push operation:

0. **Before staging anything**, confirm which profile to use. If the user has not named one, ask. Never assume the default profile on a repo that belongs to musa or musathedev.
1. If the user names a profile ("push to musa", "push to dev musa", "push to musathedev", "push to MusaTheDev001"), look it up in Section 2 of this document.
2. Run `git remote -v`, `git config user.name`, and `git config user.email` first to record the current state.
3. Run `git remote set-url origin git@github-<alias>:<github-username>/<repo>.git` using the correct alias and username from Section 2.
4. Run `git config user.name "<name>"` using the exact name from Section 2.
5. Run `git config user.email "<email>"` using the exact email from Section 2.
6. Infer the repo name from the current working directory if the user has not stated it.
7. Stage, commit with a descriptive message, and push.
8. Restore the remote URL and git config to the state recorded in step 2.
9. If the user does NOT name a profile, change nothing: leave the existing default/global remote and identity exactly as they are.
10. Never use `github.com` directly in the remote URL when targeting an extra profile.

---

### 15. Quick Reference Card

```
PROFILE     | SSH ALIAS          | user.name          | user.email
------------|--------------------|--------------------|-------------------------------
(default)   | (unchanged)        | (unchanged)        | (unchanged)
musa        | github-devmusa     | Musa March         | musamarch022005@gmail.com
musathedev  | github-musathedev  | Kiro Workspace     | kiroworkspace001@gmail.com

REMOTE URL FORMAT:
  git@<SSH-ALIAS>:<github-username>/<repo>.git

EXAMPLES:
  git@github-devmusa:DevMusa001/myproject.git
  git@github-musathedev:MusaTheDev001/myproject.git
```
