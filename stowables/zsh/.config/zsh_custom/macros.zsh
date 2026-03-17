
# Function to find dir and cd into it
function fzf-cd-shallow() {
    local dir=$(fd --max-depth 5 --type d | fzf \
    --prompt=" Change Dir. " \
    --height=50% \
    --layout=reverse \
    --border=rounded \
    --info=inline \
    --preview 'ls --color=always -F {} | head -20' \
    --preview-window='right:50%:wrap')

    # If a directory was selected (enter was pressed), cd into it
    if [[ -n "$dir" ]]; then
        cd "$dir"
        zle reset-prompt # Refreshes the prompt to show the new path
    fi
}

# Register function 
zle -N fzf-cd-shallow
bindkey '^w' fzf-cd-shallow

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"    ;;
      *.tar.gz)    tar xzf "$1"    ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xf "$1"     ;;
      *.tbz2)      tar xjf "$1"    ;;
      *.tgz)       tar xzf "$1"    ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function glog() {
  # Check if we are inside a valid git repository first
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Launch Neovim and instantly run the Fugitive command
    nvim -c "G log --oneline --graph --decorate --all | only"
  else
    echo "Whoops! You aren't inside a Git repository."
  fi
}
alias glog="glog"

mkcd() {
  mkdir -p "$1" && cd "$1"
}
# Function to find dir and cd into it
function fzf-cd-shallow() {
    local dir=$(fd --max-depth 5 --type d | fzf \
    --prompt=" Change Dir. " \
    --height=50% \
    --layout=reverse \
    --border=rounded \
    --info=inline \
    --preview 'ls --color=always -F {} | head -20' \
    --preview-window='right:50%:wrap')

    # If a directory was selected (enter was pressed), cd into it
    if [[ -n "$dir" ]]; then
        cd "$dir"
        zle reset-prompt # Refreshes the prompt to show the new path
    fi
}

# Register function 
zle -N fzf-cd-shallow
bindkey '^w' fzf-cd-shallow

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"    ;;
      *.tar.gz)    tar xzf "$1"    ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xf "$1"     ;;
      *.tbz2)      tar xjf "$1"    ;;
      *.tgz)       tar xzf "$1"    ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Function to search running processes and kill one
function fzf-kill() {
    # ps command varies slightly by OS. This works on macOS and most Linux.
    local pid=$(ps -ef | sed 1d | fzf \
    --prompt="󰆴 Kill PID: " \
    --height=50% \
    --layout=reverse \
    --border=rounded \
    --info=inline \
    --preview 'echo {}' \
    --preview-window='down:3:wrap' | awk '{print $2}')

    if [[ -n "$pid" ]]; then
        BUFFER="kill -9 $pid"
        zle accept-line
    fi
    zle reset-prompt
}

# Register function and bind to Ctrl+K
zle -N fzf-kill
bindkey '^x' fzf-kill

# Function to visually select and checkout a git branch
function fzf-checkout() {
    # Ensure we are in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not in a git repository."
        zle reset-prompt
        return
    fi

    # List branches, pipe to fzf, preview log, and extract the branch name
    local branch=$(git branch -a --color=always | grep -v '/HEAD\s' | sort | fzf \
    --prompt=" Checkout: " \
    --height=50% \
    --layout=reverse \
    --border=rounded \
    --ansi \
    --preview 'git log --oneline --graph --color=always $(sed s/^..// <<< {} | cut -d" " -f1) | head -20' \
    --preview-window='right:50%:wrap' | \
    sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/[^/]*/##')

    if [[ -n "$branch" ]]; then
        BUFFER="git checkout \"$branch\""
        zle accept-line
    fi
    zle reset-prompt
}

# Register function and bind to Ctrl+B
zle -N fzf-checkout
bindkey '^b' fzf-checkout

# Function to find a file and open it in Neovim
function fzf-edit() {
    # Uses fd to find files (includes hidden, excludes .git)
    local file=$(fd --type f --hidden --exclude .git | fzf \
    --prompt=" Edit File: " \
    --height=50% \
    --layout=reverse \
    --border=rounded \
    --info=inline \
    --preview 'bat --style=numbers --color=always {} | head -30' \
    --preview-window='right:50%:wrap')

    # If a file was selected, construct the command and run it safely in ZLE
    if [[ -n "$file" ]]; then
        BUFFER="nvim \"$file\""
        zle accept-line
    fi
    zle reset-prompt
}

# Register function and bind to Ctrl+E
zle -N fzf-edit
bindkey '^[e' fzf-edit
