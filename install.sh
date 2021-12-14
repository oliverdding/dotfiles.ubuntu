#!/usr/bin/bash

if [[ $EUID -eq 0 ]]; then
   echo "This script must NOT be run as root" 
   exit 1
fi

set -e
exec 2> >(while read line; do echo -e "\e[01;31m$line\e[0m"; done)

dotfiles_dir="$(
    cd "$(dirname "$0")"
    pwd
)"
cd "$dotfiles_dir"

#############
# Functions #
#############

link() {
    orig_file="$dotfiles_dir/$1"
    if [ -n "$2" ]; then
        dest_file="$HOME/$2"
    else
        dest_file="$HOME/$1"
    fi

    mkdir -p "$(dirname "$orig_file")"
    mkdir -p "$(dirname "$dest_file")"

    rm -rf "$dest_file"
    ln -s "$orig_file" "$dest_file"
    echo "$dest_file -> $orig_file"
}

#################
# Configuration #
#################

echo "##################"
echo "mkdir directory..."
echo "##################"

mkdir -p "$HOME"/.ssh
mkdir -p "$HOME"/.local/share/bash
mkdir -p "$HOME"/.local/share/fonts
mkdir -p "$HOME"/.local/share/gnupg
mkdir -p "$HOME"/.local/share/icons
mkdir -p "$HOME"/.local/share/pass
mkdir -p "$HOME"/.local/share/themes

chmod 700 $HOME/.ssh
chmod 700 $HOME/.local/share/gnupg
chmod 700 "$HOME"/.local/share/pass

echo "##########################"
echo "linking user's dotfiles..."
echo "##########################"

link ".profile"
link ".bashrc"

link ".config/bottom"
link ".config/environment.d"
link ".config/gdb/init"
link ".config/git/common"
link ".config/git/config"
link ".config/git/ignore"
link ".config/k9s/skin.yml"
link ".config/npm"
link ".config/nvim"
link ".config/bash_completion"
link ".config/starship.toml"

link ".local/bin/gdb"
link ".local/bin/gpg"
link ".local/bin/gpg" ".local/bin/gpg2"
link ".local/bin/ls"
link ".local/bin/sqlite3"

link ".local/share/cargo/config"
link ".local/share/gnupg/dirmngr.conf"
link ".local/share/gnupg/gpg.conf"

echo "############################"
echo "configure others dotfiles..."
echo "############################"

echo "installing vim-plug"
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
nvim +PlugInstall +qall
