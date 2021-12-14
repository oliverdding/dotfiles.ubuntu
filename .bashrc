[[ -f $XDG_DATA_HOME/cargo/env ]] && . ~/.local/share/cargo/env
[[ -f $XDG_DATA_HOME/sdkman/bin/sdkman-init.sh ]] && . "$XDG_DATA_HOME/sdkman/bin/sdkman-init.sh"

if !command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi
if !command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
