#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='lsd'
alias grep='grep --color=auto'
alias ah='nvim'
alias ..="cd .."
alias t="tmux"
alias ta="tmux attach"
alias tnw="tmux new-window"
alias tns="tmux new-session"
alias tks="tmux kill-server"
alias dwm='startx dwm'
export EDITOR='nvim'
neofetch --kitty ~/.config/neofetch/images/hey2.png



PS1='[\u@\h \W]\$ '
