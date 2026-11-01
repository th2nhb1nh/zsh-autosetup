#!/usr/bin/env bash
# Set up zsh, Oh My Zsh, custom plugins, the headline theme and zplug.
# Works on macOS (Homebrew) and Debian/Ubuntu (apt). Safe to re-run.

set -euo pipefail

OS="$(uname -s)"

# Install system packages
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    fi
    # macOS already ships zsh, curl and git
    brew install zplug
    ZPLUG_HOME="$(brew --prefix)/opt/zplug"
elif command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y zsh curl wget git
    ZPLUG_HOME="$HOME/.zplug"
    [[ -d "$ZPLUG_HOME" ]] || git clone https://github.com/zplug/zplug "$ZPLUG_HOME"
else
    echo "Unsupported system: only macOS (Homebrew) and apt-based Linux are supported." >&2
    exit 1
fi

# Install Oh My Zsh without letting it launch zsh or change the shell mid-script
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Clone the plugins ("url [target-dir]")
repos=(
    "https://github.com/zshzoo/cd-ls"
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zpm-zsh/colors.git"
    "https://github.com/zpm-zsh/colorize.git"
    "https://github.com/zdharma-continuum/history-search-multi-word.git"
    "https://github.com/aubreypwd/zsh-plugin-reload.git"
    "https://github.com/tom-auger/cmdtime.git"
    "https://github.com/MichaelAquilina/zsh-auto-notify.git auto-notify"
)

for entry in "${repos[@]}"; do
    read -r url name <<< "$entry"
    name="${name:-$(basename "$url" .git)}"
    dest="$ZSH_CUSTOM/plugins/$name"
    [[ -d "$dest" ]] || git clone --depth 1 "$url" "$dest"
done

# Clone the theme
[[ -d "$ZSH_CUSTOM/themes/headline" ]] || git clone --depth 1 https://github.com/moarram/headline.git "$ZSH_CUSTOM/themes/headline"
ln -sf "$ZSH_CUSTOM/themes/headline/headline.zsh-theme" "$ZSH_CUSTOM/themes/headline.zsh-theme"

# Update ~/.zshrc (sed -i differs between BSD and GNU, so write via a temp file)
ZSHRC="$HOME/.zshrc"
tmp="$(mktemp)"
sed -e 's/^plugins=(.*)/plugins=(git cd-ls zsh-autosuggestions zsh-syntax-highlighting colors colorize history-search-multi-word zsh-plugin-reload cmdtime auto-notify)/' \
    -e 's/^ZSH_THEME=".*"/ZSH_THEME="headline"/' \
    "$ZSHRC" > "$tmp" && cat "$tmp" > "$ZSHRC" && rm -f "$tmp"

# Append user configuration once
MARKER="# >>> zsh-autosetup >>>"
if ! grep -qF "$MARKER" "$ZSHRC"; then
    cat >> "$ZSHRC" <<EOF

$MARKER
alias c="clear"

export ZPLUG_HOME=$ZPLUG_HOME
source \$ZPLUG_HOME/init.zsh
# <<< zsh-autosetup <<<
EOF
fi

# Make zsh the default shell
ZSH_BIN="$(command -v zsh)"
if [[ "${SHELL:-}" != "$ZSH_BIN" ]]; then
    grep -qxF "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
    chsh -s "$ZSH_BIN"
fi

echo "Zsh, Oh My Zsh, plugins, theme and zplug installation complete. Please restart your terminal."
