# === History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY

# === Completion
autoload -Uz compinit
compinit -d "$HOME/.cache/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/zcompcache"

# === Shell options
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt EXTENDED_GLOB GLOB_DOTS NO_BEEP INTERACTIVE_COMMENTS
setopt PROMPT_SUBST

# === Key bindings
bindkey -e
autoload -Uz select-word-style && select-word-style bash
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[3~'   delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

# === Colors and aliases
if [[ -x /usr/bin/dircolors ]]; then
  if [[ -r "$HOME/.dircolors" ]]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# === Prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta}(%b|%a)%f'
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
PROMPT='%F{green}%n@%m%f %F{blue}%~%f${vcs_info_msg_0_} %# '

# === PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# === pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# === nvm
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# === rust
[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# === go
export PATH="$HOME/.local/go/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"

# === bitcoin
export PATH="$HOME/.local/bitcoin-32.1/bin:$PATH"

# === Claude Code account switching
# One instance per ~/.claudeN directory over a shared ~/.claude home, which
# holds skills, settings.json, CLAUDE.md and memory. Bare `claude` is claude1.
# Profiles are discovered at shell start, so a new ~/.claudeN needs no edit here.
_claude_profile() {
  local dir="$1"; shift
  local slug="${PWD//\//-}"; slug="${slug//./-}"
  local shared="$HOME/.claude/memory/$slug"
  local proj="$dir/projects/$slug"
  mkdir -p "$shared" "$proj"
  if [[ ! -L "$proj/memory" ]]; then
    [[ -d "$proj/memory" ]] && cp -rn "$proj/memory/." "$shared/" 2>/dev/null
    rm -rf "$proj/memory"
    ln -s "$shared" "$proj/memory"
  fi
  CLAUDE_CONFIG_DIR="$dir" command claude "$@"
}
for _cdir in $HOME/.claude<1-99>(N/); do
  eval "claude${${_cdir:t}#.claude}() { _claude_profile '$_cdir' \"\$@\"; }"
done
unset _cdir
claude() { _claude_profile "$HOME/.claude1" "$@"; }
claude-profiles() {
  local d
  for d in $HOME/.claude<1-99>(N/); do
    print -r -- "claude${${d:t}#.claude} -> $d"
  done
}

# Stop Ctrl+S freezing the terminal (XON/XOFF flow control) so editors can use it
[[ -o interactive && -t 0 ]] && stty -ixon
