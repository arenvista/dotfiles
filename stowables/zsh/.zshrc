# =============================================================================
# 1. ENVIRONMENT VARIABLES & PATHS
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.config/zsh_custom"
export EDITOR="vi"

# Prepend Cargo to PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Load secret keys
source "$HOME/.secret_keys/openai.env"

# =============================================================================
# 2. OH MY ZSH CONFIGURATION
# =============================================================================
ZSH_THEME="robbyrussell"

# Plugins array (added 'copypath' and 'extract' from your notes)
plugins=( git z sudo web-search copypath extract)

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# =============================================================================
# 3. USER ALIASES & MACROS
# =============================================================================
source $ZSH_CUSTOM/aliases.zsh
source $ZSH_CUSTOM/macros.zsh

# =============================================================================
# 4. SYSTEM-INSTALLED PLUGINS (Order matters here!)
# =============================================================================
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# =============================================================================
# 5. NODE VERSION MANAGER (NVM)
# =============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# =============================================================================
# 6. STARTUP SCRIPTS
# =============================================================================
# Placed last so it doesn't block the shell from initializing quickly
neofetch
