# General
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --git --group-directories-first"
alias la="eza -la --icons --git --group-directories-first"
alias tree="eza --tree --icons"
alias cat="bat"
alias grep="rg"
# fd does not support all find arguments, so we use a short alias instead of overriding
alias f="fd"
alias cd="z"

# Git
alias g="git"
alias lg="lazygit"

# Neovim
alias v="nvim"
alias vim="nvim"

# Chezmoi
alias cm="chezmoi"
alias cma="chezmoi apply"
alias cmu="chezmoi update"
alias cme="chezmoi edit"

# Misc
alias reload="source ~/.zshrc"
