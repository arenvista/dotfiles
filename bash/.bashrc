#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#alias ls='lsd'
alias grep='grep --color=auto'
alias ah='nvim'
alias ta="tmux-attacher"
alias ..="cd .."
alias ls="lsd"
alias t="tmux"
alias tnw="tmux new-window"
alias tns="tmux new-session"
alias tks="tmux kill-server"
alias dwm='startx dwm'
export EDITOR='nvim'
neofetch --kitty ~/wallpapers/favorites/nier_2x.png
PS1='[\u@\h \W]\$ '
bind -s '"\016": "nvim\n"'
alias cdf="cd \$(find -mindepth 1 -maxdepth 1 -type d | fzf)" 
kill -SIGUSR1 $(pidof kitty) # Reload kitty colorscheme

