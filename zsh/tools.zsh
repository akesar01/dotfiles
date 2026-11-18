# Sourced from ~/.zshrc (after compinit). Order matters: atuin last so it owns Ctrl-R.

# fzf: Ctrl-T pick file, Alt-C cd into dir, **<Tab> fuzzy completion
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
source <(fzf --zsh)
bindkey '\ec' fzf-cd-widget   # Alt-C (Option-C on macOS sends Esc+c in WezTerm)

# zoxide: `z <part of name>` jumps to a frecent dir, `zi` picks with fzf
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# starship prompt (config: ~/.config/starship.toml -> dotfiles/starship)
command -v starship >/dev/null && eval "$(starship init zsh)"

# atuin: Ctrl-R full-screen history search (up arrow left as normal)
command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
