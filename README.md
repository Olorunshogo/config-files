# config-files

One repository for the things that make a machine mine: shell and editor
dotfiles, agent configuration, reusable AI skills, agent memory, and the setup
guides that explain how they fit together.

It is organised into four categories, each self-contained so a machine can fetch
only the part it needs:

| Folder | What it holds | Who fetches it |
| --- | --- | --- |
| `Config/` | Dotfiles, mirroring `$HOME` path for path | Any machine being set up |
| `Skills/` | Reusable AI agent skills (`Core/` mine, `Aura/` vendored) | Machines running Claude Code |
| `Memory/` | Genericized agent memory: conventions and project constraints | Machines running Claude Code |
| `Guides/` | Prose setup docs that are read, not loaded | Humans, and agents on request |

## Repository structure

```text
.
├── Config/                      # mirrors $HOME path for path
│   ├── .claude/
│   │   ├── CLAUDE.md            # global agent instructions
│   │   ├── settings.json        # permissions, model, plugins, UI
│   │   └── statusline-command.sh
│   ├── .config/
│   │   ├── git/config           # identity, signing, aliases, merge tools
│   │   ├── git/ignore           # global gitignore
│   │   ├── nvim/                # LazyVim config
│   │   └── shell/env            # cross-shell XDG environment
│   ├── .ssh/config              # host aliases per GitHub account (no keys)
│   ├── .bashrc  .bash_profile  .profile
│   ├── .zshrc
│   └── .vimrc  .nuxtrc
├── Guides/
│   ├── git-profile.md           # quick reference: which profile for which repo
│   ├── git-profiles-prompt.md   # the instruction an agent reads before pushing
│   ├── git-profiles-guide.md    # full walkthrough, as configured here
│   ├── git-profiles-guide-template.md  # the same, with placeholders to fill in
│   └── MultipleGitAccount.md    # long-form setup guide
├── Memory/
│   ├── MEMORY.md                # index, one line per memory
│   ├── feedback/                # how an agent should work: locked conventions
│   └── project/                 # standing project constraints
├── Skills/
│   ├── Core/                    # own skills, kept in sync with ~/.claude/skills
│   └── Aura/                    # vendored Aura design and motion skill pack
├── LICENSE
└── README.md
```

## Setup

### 1. Clone

Full clone, for a machine that wants everything:

```bash
git clone git@github.com:Olorunshogo/config-files.git ~/Projects/Others/config-files
```

Dotfiles only, skipping the skill packs entirely:

```bash
git clone --filter=blob:none --no-checkout --sparse git@github.com:Olorunshogo/config-files.git
git -C config-files sparse-checkout set Config
git -C config-files checkout
```

Only the blobs inside `Config/` are ever downloaded. Git still fetches the list
of file names in the other folders, but none of their contents. Needs git 2.25
or newer. Updating later is a `git pull` in that folder and still brings
`Config/` only.

### 2. Link the dotfiles

Every path under `Config/` maps to the same path under `$HOME`, so linking is
mechanical. Back up whatever is already there first:

```bash
cd ~/Projects/Others/config-files/Config
find . -type f -print0 | while IFS= read -r -d '' f; do
  rel="${f#./}"
  dest="$HOME/$rel"
  [ -e "$dest" ] && [ ! -L "$dest" ] && mv "$dest" "$dest.backup"
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$PWD/$rel" "$dest"
done
```

Symlinks mean a `git pull` updates the live config with no second step.
Prefer copies if a tool rejects symlinked config.

### 3. Fill in the machine-specific values

Three files carry values that are per-machine or per-account and need checking
after linking:

- `.config/git/config` - `user.name`, `user.email`, `user.signingkey`, the
  `credential.helper` path and `gpg.ssh.allowedSignersFile` all point at
  absolute paths under one home directory.
- `.ssh/config` - names one `Host` alias per GitHub account and the
  `IdentityFile` each uses. The keys themselves are never in this repo; generate
  them with `ssh-keygen -t ed25519 -f ~/.ssh/<name>` and add the public half to
  the matching GitHub account.
- `.claude/settings.json` - `additionalDirectories` and the `statusLine` command
  are absolute paths.

### 4. Wire up the skills

Claude Code reads skills from `~/.claude/skills`. Point it at this repo rather
than copying, so an update is a pull:

```bash
for s in ~/Projects/Others/config-files/Skills/Core/*/; do
  ln -sfn "$s" "$HOME/.claude/skills/$(basename "$s")"
done
```

`Skills/Aura` is a large vendored pack. Link only the entries actually wanted,
since every skill in that directory costs context on load.

### 5. Multiple Claude profiles on one machine

`.zshrc` and `.bashrc` define a `claude1`..`claudeN` function set: each profile
is its own `~/.claudeN` directory with its own login, over a single shared
`~/.claude` home holding skills, `settings.json`, `CLAUDE.md` and memory. Bare
`claude` resolves to `claude1`. Profiles are discovered at shell start, so
adding `~/.claude5` needs no edit. Run `claude-profiles` to list what resolved.

### 6. Multiple GitHub accounts

Read `Guides/git-profiles-guide.md`. The one idea to keep: `user.name` and
`user.email` only label a commit. The SSH host alias in the remote URL decides
which GitHub account receives the push.

## Keeping this repo and the machine in sync

The live machine is the source of truth for `Config/` and `Skills/Core/`, so
drift shows up as a diff against `~`:

```bash
# which tracked dotfiles have drifted
cd ~/Projects/Others/config-files/Config
find . -type f -exec sh -c 'diff -q "$1" "$HOME/${1#./}" >/dev/null || echo "${1#./}"' _ {} \;

# which skills have drifted
diff -rq ~/Projects/Others/config-files/Skills/Core ~/.claude/skills 2>/dev/null | grep differ
```

`Guides/` runs the other way: the versions here are the maintained, genericized
rewrites, and `~/.claude` holds the older personal copies.

## What is deliberately not tracked

| Excluded | Why |
| --- | --- |
| `~/.config/git/credentials` | Plaintext credential store |
| `~/.ssh/id_*` and any private key | Secrets |
| Shell and command history | Noise, and leaks paths and tokens |
| `~/.claude/projects`, `sessions`, `cache`, `history.jsonl`, `telemetry` | Per-machine agent state |
| Cloudflare and other marketplace skills | Symlinks into a plugin marketplace, reproduced by `extraKnownMarketplaces` in `settings.json` |
| Per-project memory under `~/.claude/memory` | Keyed by absolute paths; `Memory/` holds the genericized distillation |

### Example env files are never ignored

`.env` and its real variants are ignored everywhere, but every documentation
form stays trackable, in both this repo's `.gitignore` and the global
`Config/.config/git/ignore`: `.env.example`, `.env.<name>.example`,
`<name>.env.example`, `example.env`, `sample.env`, `.env.sample` and
`.env.template`. A committed example file is the only record of which variables
an app needs, so losing it to a broad `.env*` pattern is a real cost.

## Skills

`Skills/Core` holds skills written for this setup, covering frontend
architecture and component conventions, coding style and comment rules, modal
and motion patterns, React and shadcn/ui components, Supabase and Postgres
practice, Ethereum development (a full ETHSkills mirror), Bitcoin and Rust
open-source contribution workflow, workspace and IDE scaffolding, and prompt
authoring.

`Skills/Aura` is a vendored pack of roughly a hundred design, motion and
frontend-craft skills: GSAP, Three.js, WebGL, Tailwind systems, landing page and
conversion patterns, art direction, and visual effect recipes.

The live web version of ETHSkills is at
[termo.ai/skills/ethskills](https://termo.ai/skills/ethskills).

## Future plans

- [ ] **`ipile` installer.** A single command that clones `Config/` sparsely,
      backs up existing files, links everything into `$HOME`, and reports what
      it changed - replacing the shell loop in step 2 above. macOS and Linux.
- [ ] **Generic base plus personal overlay.** Split the shell files so `ipile`'s
      generic setup and personal additions stop competing for the same file:
      `.zshrc` and `.bashrc` source `.zshrc.local` and `.bashrc.local`, which
      hold only the personal parts (the Claude profile functions, the Bitcoin
      path). The committed base then works on a machine that is not mine.
- [ ] **Genericize what still carries personal values.** `.config/git/config`,
      `.ssh/config`, `.claude/settings.json` and `Skills/Core/drips` name real
      accounts, repos and absolute home paths. Each becomes a `.example` with
      `<placeholder>` values, matching how `Guides/` is already written.
- [ ] **A drift check that runs itself.** Promote the sync commands above into a
      script, then a pre-commit hook or a scheduled job, so `Config/` and
      `Skills/Core/` never silently fall behind the machine.
- [ ] **Decide one repo or two.** Dotfiles and skill packs have different
      audiences and very different sizes. Sparse checkout makes one repo
      workable for now; a split stays open if `Skills/Aura` keeps growing.
- [ ] **Widen `Config/` coverage.** Ghostty, VS Code settings and keybindings,
      `tmux`, and a `.editorconfig` are all unmanaged today.
- [ ] **CI on the configs.** Lint shell files with `shellcheck`, validate the
      JSON, and assert that no secret pattern or absolute home path has entered
      a tracked file.

## License

See [LICENSE](LICENSE).
