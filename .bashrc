if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    set -a
    . /dev/fd/0 <<EOF
$(/usr/lib/systemd/user-environment-generators/30-systemd-environment-d-generator)
EOF
    set +a
fi

[[ -f $XDG_DATA_HOME/cargo/env ]] && . ~/.local/share/cargo/env
[[ -f $XDG_DATA_HOME/sdkman/bin/sdkman-init.sh ]] && . "$XDG_DATA_HOME/sdkman/bin/sdkman-init.sh"

eval "$(zoxide init bash)"
eval "$(starship init bash)"
