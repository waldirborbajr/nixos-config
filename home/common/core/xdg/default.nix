{ lib, ... }:

{
  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    # XDG base
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";

    # Dev / Toolchains
    CARGO_HOME = "$XDG_DATA_HOME/cargo";
    RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
    GOPATH = "$XDG_DATA_HOME/go";
    NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
    STACK_ROOT = "$XDG_DATA_HOME/stack";

    # Security / Secrets (FORÇADO)
    GNUPGHOME = lib.mkForce "$XDG_DATA_HOME/gnupg";
    PASSWORD_STORE_DIR = "$XDG_DATA_HOME/pass";

    # History / Less
    HISTFILE = "$XDG_STATE_HOME/history";
    LESSHISTFILE = "-";

    # X / Session
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    # Shell
    ZDOTDIR = "$HOME/.config/zsh";
  };
}
