#!/usr/bin/bash

if [[ $EUID -eq 0 ]]; then
   echo "This script must NOT be run as root" 
   exit 1
fi

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log" >&2)

script_name="$(basename "$0")"
dotfiles_dir="$(
    cd "$(dirname "$0")"
    pwd
)"
cd "$dotfiles_dir"

copy() {
    orig_file="$dotfiles_dir/$1"
    dest_file="/$1"

    sudo mkdir -p "$(dirname "$orig_file")"
    sudo mkdir -p "$(dirname "$dest_file")"

    sudo rm -rf "$dest_file"

    sudo cp -R "$orig_file" "$dest_file"
    echo "$dest_file <= $orig_file"
}

sudo apt-get -y update

sudo apt -y --no-install-recommends install gnupg2 apt-transport-https software-properties-common ca-certificates curl zip unzip tar locales lsb-release
sudo locale-gen en_US.UTF-8 
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo add-apt-repository -y ppa:longsleep/golang-backports

copy "etc/apt/sources.list.d/docker.list"
#copy "etc/apt/sources.list.d/kubernetes.list"
copy "etc/apt/sources.list"
copy "etc/sudoers.d/override"
copy "etc/hostname"
copy "etc/motd"
copy "etc/timezone"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

O_USER=$USER
for GROUP in wheel network video input docker; do
    sudo groupadd -rf "$GROUP"
    sudo gpasswd -a "$O_USER" "$GROUP"
done

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt -y --no-install-recommends install docker-ce docker-ce-cli containerd.io
sudo apt -y --no-install-recommends install dash openssl libssl-dev neovim git bash-completion fzf hexyl
sudo apt -y --no-install-recommends install gcc-10 g++-10 python3 python3-dev python3-pip python3-setuptools python3-wheel golang 
sudo apt -y autoremove

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 50
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 50

sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100
sudo update-alternatives --set cc /usr/bin/gcc

sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100
sudo update-alternatives --set c++ /usr/bin/g++

mkdir -p ~/.local/share/cargo/
cp ./.local/share/cargo/config ~/.local/share/cargo/config

export RUSTUP_HOME=~/.local/share/rustup
export CARGO_HOME=~/.local/share/cargo
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -q -y --default-host x86_64-unknown-linux-gnu --no-modify-path --default-toolchain nightly --profile default --component llvm-tools-preview clippy rust-analyzer-preview rust-src
source ~/.local/share/cargo/env
cargo install starship git-delta zoxide exa ripgrep cargo-update cargo-edit

export SDKMAN_DIR=~/.local/share/sdkman
curl -s "https://get.sdkman.io" | bash
source ~/.local/share/sdkman/bin/sdkman-init.sh
sdk install java 8.0.312-zulu
sdk default java 8.0.312-zulu
sdk install gradle 7.3.1
sdk default gradle 7.3.1
sdk install scala 2.12.15
sdk default scala 2.12.15
sdk install sbt 1.5.6
sdk default sbt 1.5.6
rm -rf ~/.local/share/sdkman/tmp/*
