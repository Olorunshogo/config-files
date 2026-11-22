# Multiple Git Accounts on One Machine (template)

How one machine pushes to several GitHub accounts from one user account, and the rules an assistant (or a person) follows before every commit and push. It works the same for one extra account or ten.

## How to fill this in

Every value in `<angle brackets>` is yours to replace. Accounts are numbered `1` to `N`: copy the row or block marked `1` once per extra account, and change the number.

| Placeholder | Meaning | Example |
| --- | --- | --- |
| `<profile-N>` | The word you say: "push to `<profile-N>`" | `work` |
| `<trigger-words-N>` | Other names that mean the same profile | `office, job` |
| `<alias-N>` | The SSH host alias, used as `github-<alias-N>` | `work` |
| `<username-N>` | That account's GitHub username | `jane-at-acme` |
| `<Name-N>` | The commit author name | `Jane Doe` |
| `<email-N>` | The commit author email | `jane@acme.com` |
| `<key-N>` | The SSH key file name, as `~/.ssh/id_ed25519_<key-N>` | `work` |

Your **default account** (the one plain `git push` already uses) is not numbered and is never changed by this setup. If you have no default account and only want named profiles, every repo must use one of the aliases.

The guide combines three files an assistant can be given:

| Part | File | What it is |
| --- | --- | --- |
| 1 | `~/.claude/git-profiles-prompt.md` | The short instruction |
| 2 | `~/.claude/git-profiles.md` | Quick reference index |
| 3 | `~/.claude/MultipleGitAccounts.md` | Full setup and usage guide |

**The one idea to keep:** `user.name` and `user.email` only label a commit. The SSH host alias in the remote URL decides which GitHub account receives the push.

---

## Part 1: The short prompt

_The instruction an assistant is given. It points at the two documents below._

This machine has extra GitHub profiles (`<profile-1>`, `<profile-2>`, ... `<profile-N>`) on top of the normal default account. Before any commit or push, check `~/.claude/git-profiles.md` (quick reference) and `~/.claude/MultipleGitAccounts.md` (full guide) for how to handle "push to `<profile-N>`" requests.

**Pre-commit rule:** Before staging or committing anything, establish which profile the commit should be authored as. If the user has not named a profile, ask before committing. Never assume the default profile on a repo that belongs to one of the extra accounts.

If no profile is named and the repo is the user's normal default repo, change nothing and push normally to the existing default account.

---

## Part 2: Quick reference (`git-profiles.md`)

_The one-page lookup: which name maps to which identity, and the steps for a profile-targeted push._

### Profiles

This machine has **N extra GitHub profiles** on top of the default global profile, which stays untouched and is used for normal manual `git push`.

**When the user says "push to [name]", look the name up below, apply all of that profile's settings, then commit and push. No questions needed.**

| Alias triggers | user.name | user.email | GitHub username | SSH host alias |
| --- | --- | --- | --- | --- |
| `<profile-1>` / `<trigger-words-1>` | `<Name-1>` | `<email-1>` | `<username-1>` | `github-<alias-1>` |
| `<profile-2>` / `<trigger-words-2>` | `<Name-2>` | `<email-2>` | `<username-2>` | `github-<alias-2>` |
| ... one row per extra account | | | | |

**Default or unnamed push:** leave the remote and git config exactly as they are (the global profile). Never switch to a named profile unless the user names it.

**Remote URL pattern:** `git@github-<alias-N>:<username-N>/<repo>.git`

**Repo name:** infer it from the current working directory if it is not stated.

### Steps before a profile-targeted commit and push

1. Run `git remote -v` to check the current remote URL.
2. Save the current remote URL, `user.name` and `user.email`, so they can be restored afterwards.
3. Set the remote URL to the target profile's SSH alias.
4. Set `git config user.name` for that profile.
5. Set `git config user.email` for that profile.
6. Stage, commit, push.
7. Restore the remote URL and git config saved in step 2, so a plain `git push` afterwards still goes to the default account.

### Per-profile commands

The same three commands for every profile. Swap in that profile's values:

```bash
git remote set-url origin git@github-<alias-N>:<username-N>/<repo>.git
git config user.name "<Name-N>"
git config user.email "<email-N>"
```

### Pre-commit profile check (required)

1. If the user has named a profile in this session ("push to `<profile-N>`", "commit as `<profile-N>`"), use it for every commit in the session.
2. If no profile has been named, ask: "Which profile should this commit be authored as: default, `<profile-1>`, `<profile-2>`, ...?" before staging anything.
3. Never assume the default profile for a repo that belongs to one of the extra accounts.
4. Once a profile is set for a session, use it for every commit without asking again.

### Key rules

- Never push to a named profile without first setting its remote URL and git config.
- `user.name` and `user.email` only label the commit. The SSH alias in the remote URL decides which account receives the push.
- After a profile-targeted push, restore the remote URL and git config so the user's manual pushes are unaffected.
- Infer the repo name from the current directory if it is not given.
- Any trigger word in the profiles table selects that profile automatically.
- A normal `git push` with no profile named is never redirected.

---

## Part 3: Full guide (`MultipleGitAccounts.md`)

_How the setup works, keys and SSH config, testing, setting up from scratch, and common mistakes._

### 1. The core concept

Git does not choose which GitHub account to push to based on `user.name` or `user.email`. Those only label the commit author.

The account used when pushing is decided by:

1. The **remote URL**, specifically the SSH host alias in it
2. The **SSH config**, which maps that alias to one private key
3. The **SSH key**, which is registered on one GitHub account

```
Remote URL  ->  selects which SSH alias to use
SSH alias   ->  maps to a specific private key (~/.ssh/config)
Private key ->  is registered on a specific GitHub account
GitHub      ->  authenticates and accepts the push as that account
git config  ->  only labels who authored the commit (name/email)
```

So:

- Changing `git config user.name` alone does not switch accounts.
- To push to the right account you must change the remote URL to that account's SSH alias.
- You must also set `user.name` and `user.email` so commits are labelled correctly.
- The default profile is untouched. A plain `git push` with no profile named works as it always has.

This scales to any number of accounts: each extra account is one more key, one more `Host` block and one more alias. Nothing else changes.

### 2. The profiles

| Profile | user.name | user.email | SSH host alias | GitHub username |
| --- | --- | --- | --- | --- |
| (default, unnamed) | unchanged | unchanged | unchanged | unchanged |
| `<profile-1>` / `<trigger-words-1>` | `<Name-1>` | `<email-1>` | `github-<alias-1>` | `<username-1>` |
| `<profile-2>` / `<trigger-words-2>` | `<Name-2>` | `<email-2>` | `github-<alias-2>` | `<username-2>` |
| ... one row per extra account | | | | |

### 3. SSH keys

Each extra account has its own key pair in `~/.ssh/`:

| Profile | Private key | Public key |
| --- | --- | --- |
| `<profile-1>` | `~/.ssh/id_ed25519_<key-1>` | `~/.ssh/id_ed25519_<key-1>.pub` |
| `<profile-2>` | `~/.ssh/id_ed25519_<key-2>` | `~/.ssh/id_ed25519_<key-2>.pub` |
| ... one row per extra account | | |

Each public key is registered on its own GitHub account under `Settings -> SSH and GPG Keys`. A GitHub account can hold several keys, but **one key can only belong to one account**, which is why every account needs its own.

A key's file name does not have to match the profile name. What matters is that `~/.ssh/config` points each alias at the right file.

The default account's key (usually `~/.ssh/id_ed25519`) is untouched.

### 4. SSH config (`~/.ssh/config`)

One `Host` block per extra account, added below anything already in the file:

```
# <profile-1> (<username-1>)
Host github-<alias-1>
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_<key-1>
  IdentitiesOnly yes

# <profile-2> (<username-2>)
Host github-<alias-2>
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_<key-2>
  IdentitiesOnly yes

# ...one block per extra account
```

`IdentitiesOnly yes` matters once there are several keys: without it, ssh may offer a key loaded in the agent first, and GitHub accepts the push as whichever account owns that key.

The default behaviour (whatever key `ssh -T git@github.com` used before) is untouched. These aliases are additive.

To edit: `nano ~/.ssh/config`

### 5. Testing each connection

```bash
ssh -T git@github-<alias-1>
ssh -T git@github-<alias-2>
# ...one line per extra account
```

Each should answer:

```
Hi <username-N>! You've successfully authenticated, but GitHub does not provide shell access.
```

Check that every alias greets its own username. Two aliases greeting the same username means two `Host` blocks point at the same key.

Exit code 1 is normal here: GitHub closes the session after the greeting.

### 6. Remote URL format

When targeting an extra account, the remote URL uses the SSH alias, not `github.com`.

**Wrong** (uses the default account):

```
git@github.com:<username-N>/<repo>.git
```

**Right:**

```
git@github-<alias-N>:<username-N>/<repo>.git
```

For the default account, keep whatever remote URL the repo already has.

### 7. Per-profile commands

Before committing and pushing as a profile:

```bash
git remote set-url origin git@github-<alias-N>:<username-N>/<repo>.git
git config user.name "<Name-N>"
git config user.email "<email-N>"
```

Use the values from that profile's row in Section 2. Infer `<repo>` from the current directory if it is not stated.

After the push, restore the remote URL and git config to what they were, so the next manual `git push` goes to the default account.

### 8. Mandatory pre-commit and pre-push checklist

**Before staging anything**, establish the profile:

- If the user has named a profile in this session, use it for every commit in the session.
- If no profile has been named, ask: "Which profile should this commit be authored as: default, `<profile-1>`, `<profile-2>`, ...?"
- Never assume the default profile for a repo owned by one of the extra accounts.

Then, for every commit and push to an extra account, in order:

1. **Record the current remote and identity:**
   ```bash
   git remote -v
   git config user.name
   git config user.email
   ```
2. **Set the remote URL** to the profile's SSH alias (Section 7).
3. **Set `user.name`** for the profile.
4. **Set `user.email`** for the profile.
5. **Stage:**
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
8. **Restore** the remote URL and identity recorded in step 1.

Never skip steps 2, 3 or 4. Never use `github.com` in the remote URL when targeting an extra account.

### 9. Cloning a repo for a profile

Use the alias in the URL from the start:

```bash
git clone git@github-<alias-N>:<username-N>/<repo>.git
cd <repo>
git config user.name "<Name-N>"
git config user.email "<email-N>"
```

For the default account, clone as you always have.

### 10. Switching an existing repo

```bash
# What it is now
git remote -v

# Point it at an extra account
git remote set-url origin git@github-<alias-N>:<username-N>/<repo>.git

# Or put back the default remote you noted before switching
git remote set-url origin <original-url>
```

### 11. Verifying before a push

```bash
git remote -v            # the right SSH alias?
git config user.name     # the right author?
git config user.email
git branch               # the right branch?
ssh -T git@github-<alias-N>   # the key reaches the right account?
```

### 12. Setting up from scratch

Repeat steps 1 to 4 once per extra account, then do steps 5 and 6 once.

**Step 1: generate a key**

```bash
ssh-keygen -t ed25519 -C "<email-N>" -f ~/.ssh/id_ed25519_<key-N>
```

Set a passphrase for extra security, or add `-N ""` for none if automated pushes must not prompt.

**Step 2: add it to the SSH agent (if you use one)**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_<key-N>
```

**Step 3: copy the public key**

```bash
cat ~/.ssh/id_ed25519_<key-N>.pub
```

**Step 4: add it to the matching GitHub account**

1. Log into that account.
2. Go to `Settings -> SSH and GPG Keys -> New SSH key`.
3. Paste the public key.
4. Name it after the machine and profile, for example `laptop-<profile-N>`.

**Step 5: write the SSH config**

Add one `Host` block per account from Section 4. Do not remove or change entries already in the file.

**Step 6: test every connection**

Run Section 5 for each alias and check each one greets its own username.

**Adding another account later** is the same four steps for the new account, plus one more `Host` block and one more row in the profiles table. Existing accounts are not touched.

### 13. Common mistakes

| Mistake | Why it is wrong |
| --- | --- |
| Using `git@github.com:...` for an extra account | Uses the default key and pushes to the wrong account |
| Only changing `user.name` / `user.email` | Labels the commit but does not switch accounts |
| Forgetting `git remote set-url` | The push goes to the wrong account |
| Reusing one key on two accounts | GitHub rejects it: a key can belong to only one account |
| Two `Host` blocks pointing at the same key | Both aliases push as the same account |
| Leaving out `IdentitiesOnly yes` with several keys | ssh may offer an agent key first and log in as the wrong account |
| Skipping `ssh -T` after setup | You will not know if a key is linked to the right account |
| Not restoring the remote and identity after a profile push | The next manual `git push` silently goes to the wrong account |
| Cloning with `github.com` for an extra account | The repo is tied to the wrong account from the start |
| Using an alias that was renamed or retired | ssh cannot resolve it and the push fails |

### 14. Instructions for an assistant given this document

0. **Before staging anything**, confirm the profile. If the user has not named one, ask. Never assume the default profile on a repo that belongs to an extra account.
1. If the user names a profile or any of its trigger words, look it up in Section 2.
2. Run `git remote -v`, `git config user.name` and `git config user.email` to record the current state.
3. Run `git remote set-url origin git@github-<alias-N>:<username-N>/<repo>.git` with that profile's values.
4. Run `git config user.name "<Name-N>"`.
5. Run `git config user.email "<email-N>"`.
6. Infer the repo name from the current directory if it is not given.
7. Stage, commit with a descriptive message, and push.
8. Restore the remote URL and git config recorded in step 2.
9. If no profile is named, change nothing: leave the default remote and identity as they are.
10. Never use `github.com` in the remote URL when targeting an extra account.

### 15. Quick reference card

```
PROFILE        | SSH ALIAS           | user.name   | user.email
---------------|---------------------|-------------|-------------
(default)      | (unchanged)         | (unchanged) | (unchanged)
<profile-1>    | github-<alias-1>    | <Name-1>    | <email-1>
<profile-2>    | github-<alias-2>    | <Name-2>    | <email-2>
...            | one line per extra account

REMOTE URL FORMAT:
  git@github-<alias-N>:<username-N>/<repo>.git

EXAMPLE (two accounts, work and personal):
  git@github-work:jane-at-acme/api.git
  git@github-personal:janedoe/dotfiles.git
```
