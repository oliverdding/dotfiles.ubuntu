#!/bin/sh

set -e
exec 2> >(while read line; do echo -e "\e[01;31m$line\e[0m"; done)

dotfiles_dir="$(
    cd "$(dirname "$0")"
    pwd
)"
cd "$dotfiles_dir"

apt autoremove gcc-9-base gcc-9 gcc python2.7 python2.7-minimal python-minimal python-pip-whl python python3 python3.8 python3.8-minimal ruby wget ruby2.7 vim vim-common x11-common x11-utils
