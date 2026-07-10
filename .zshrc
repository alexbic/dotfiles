ZSH_DISABLE_COMPFIX="true"

# PATH configuration
export PATH="$HOME/.npm-global/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Homebrew for Linux
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="gnzh"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "linuxonly" "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#plugins=(git)
plugins=(git tmux zsh-autosuggestions zsh-syntax-highlighting jsontools history colored-man-pages)

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root)
# Declare the variable
typeset -A ZSH_HIGHLIGHT_PATTERNS
typeset -gA ZSH_HIGHLIGHT_STYLES

# To have commands starting with `rm -rf` in red:
ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')

ZSH_HIGHLIGHT_STYLES[root]='bg=red'
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=red,bold' 
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='fg=gray,bold'

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
#
# # ---- Eza (better ls) -----
alias ls="eza --icons=always"

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

# OpenClaw Completion (только на серверах, где установлен OpenClaw)
[[ -f "/home/wiz/.openclaw/completions/openclaw.zsh" ]] && source "/home/wiz/.openclaw/completions/openclaw.zsh"

# === Подключение к tmux (tmux-attach) ===
# Простое подключение к tmux
# Использование: tmux-attach [имя_сессии]
tmux-attach() {
    local SESSION_NAME="${1:-OpenClaw}"
    tmux attach -t "$SESSION_NAME" 2>/dev/null || tmux new-session -s "$SESSION_NAME"
}

# Алиас для быстрого подключения
alias ta="tmux-attach OpenClaw"

# === Авто-обёртка claude в Herdr (портировано с tmux-версии) ===
# Внутри Herdr ($HERDR_ENV задан) — просто запускает claude как обычно.
# Вне Herdr — ищет workspace, у которого root cwd совпадает с текущей папкой:
#   - если нашёлся — просто подключается (herdr сам фокусирует нужный workspace по cwd);
#   - если нет — создаёт workspace для этой папки, запускает в нём claude, затем подключается.
claude() {
    if [[ -n "$HERDR_ENV" ]]; then
        command claude "$@"
        return
    fi

    if ! command -v herdr >/dev/null 2>&1; then
        command claude "$@"
        return
    fi

    local cwd="$PWD"
    local existing_workspace
    existing_workspace=$(herdr pane list 2>/dev/null | jq -r --arg cwd "$cwd" \
        '.result.panes[]? | select(.cwd == $cwd) | .workspace_id' 2>/dev/null | head -n1)

    if [[ -z "$existing_workspace" ]]; then
        local label
        label=$(basename "$cwd" | tr -c 'a-zA-Z0-9_-' '-')
        local pane_id
        pane_id=$(herdr workspace create --cwd "$cwd" --label "$label" --focus 2>/dev/null \
            | jq -r '.result.root_pane.pane_id' 2>/dev/null)
        if [[ -n "$pane_id" && "$pane_id" != "null" ]]; then
            # Ждём готовности шелла в новой панели (иначе .zshrc/nvm ещё не
            # успели отработать, и PATH не содержит claude — гонка).
            herdr wait output "$pane_id" --match '➤' --timeout 5000 >/dev/null 2>&1
            herdr pane run "$pane_id" "command claude ${(q@)@}" >/dev/null 2>&1
        fi
    fi

    herdr
}

export PATH=$PATH:~/go/bin
umask 0022
