#!/bin/bash

sudo apt update
sudo apt install -y zsh
which zsh
zsh
sudo apt install -y curl wget git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
echo $SHELL

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
cd $ZSH_CUSTOM/plugins
repos=(
    "https://github.com/zshzoo/cd-ls"
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zpm-zsh/colorize.git"
    "https://github.com/zdharma-continuum/history-search-multi-word.git"
    "https://github.com/aubreypwd/zsh-plugin-reload.git"
    "https://github.com/tom-auger/cmdtime.git"
    "https://github.com/MichaelAquilina/zsh-auto-notify.git auto-notify"
)

for repo in "${repos[@]}"; do
    git clone $repo
done

sed -i 's/plugins=(git)/plugins=(git cd-ls zsh-autosuggestions zsh-syntax-highlighting colorize history-search-multi-word zsh-plugin-reload cmdtime auto-notify)/' ~/.zshrc
source ~/.zshrc

echo "Zsh, Oh My Zsh, and plugins installation complete. Please restart your terminal."
