alias install="sudo pacman -S"
alias update="sudo pacman -Sy"

alias ah="nvim"
alias ..="cd .."
alias ls="lsd"
alias l="ls"

bindkey -s '^s' "tmux-attacher\n"
bindkey -s '^f' "tmux-sessionizer\n"

bindkey -s '^[' "source ~/.zshrc\n"
bindkey -s '^n' "nvim\n"
bindkey -s '^y' "yazi\n"
