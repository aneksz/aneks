# =====================================================
# ~/.zshrc - Clean Arch setup with Powerlevel10k + FAST highlighting
# =====================================================

# -----------------------------
# 1️⃣ Completely disable zsh-syntax-highlighting
# -----------------------------
typeset -g ZSH_HIGHLIGHT_DISABLED=1

# Redefine phantom ZLE widgets to no-op to suppress warnings
for w in menu-search recent-paths; do
    if zle -l | grep -q "^$w\$"; then
        zle -N "$w" '' 2>/dev/null
    fi
done

# -----------------------------
# 2️⃣ Powerlevel10k Instant Prompt
# -----------------------------
fastfetch -c ~/.local/share/fastfetch/13.jsonc --logo /home/igor/Downloads/images/anime-girl.png --logo-type kitty --logo-width 20 --logo-height 8

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------
# 3️⃣ Oh My Zsh
# -----------------------------
export ZSH="$HOME/.oh-my-zsh"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# -----------------------------
# 4️⃣ Zsh completions
# -----------------------------
autoload -Uz compinit
compinit

# -----------------------------
# 5️⃣ FZF
# -----------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -----------------------------
# 6️⃣ Custom aliases
# -----------------------------
alias s='yay -Ss'
alias i='yay -S'
alias r='yay -Rns'
alias u='yay -Syu'
alias n='nano'
alias y='yazi'
alias cat='bat'

# Theme-aware LS behavior

if command -v exa >/dev/null 2>&1; then
    alias ls='exa -lh --icons --color=auto --group-directories-first'
else
    alias ls='ls --color=auto --group-directories-first'
fi

# Waybar current directory
function cd() {
    builtin cd "$@" || return
    echo "$PWD" > ~/.cache/current_dir
}

# -----------------------------
# 7️⃣ Zsh Plugins (after OMZ and compinit)
# -----------------------------
source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Optional: autosuggestions color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

# -----------------------------
# 9️⃣ Powerlevel10k prompt (last)
# -----------------------------
[[ ! -f ~/powerlevel10k/powerlevel10k.zsh-theme ]] || source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


# -----------------------------
# 10️⃣ GTK / Wayland settings
# -----------------------------
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GDK_BACKEND=wayland

export EDITOR=nano
export VISUAL="$EDITOR"

export PATH=$PATH:/home/igor/.spicetify:$HOME/.local/bin:/usr/local/bin:$PATH

