# home/modules/atuin.nix
#
# ÚNICO dono de ~/.config/atuin/config.toml.
# NÃO usar xdg.configFile."atuin" nem programs.atuin noutro módulo (zsh.nix,
# cli-and-terminal.nix).
#
# enableZshIntegration injeta o init no zsh; --disable-up-arrow deixa as
# setas com history-substring-search (bindings no zsh.nix).
_: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = ["--disable-up-arrow"];

    settings = {
      auto_sync = false;
      # sync_address = "https://SEU-SERVIDOR-AQUI";

      style = "compact";
      inline_height = 0;

      history_filter = [
        "^cd"
        "^clear"
        "^e"
        "^exit"
        "^htop"
        "^ls"
        "^rm"
        "^shred"
        "^z"
      ];

      enter_accept = true;
      theme.name = "catppuccin-mocha";
      ai.enabled = false;

      daemon = {
        enabled = false;
        autostart = false;
      };

      tmux = {
        enabled = true;
        width = "80%";
        height = "60%";
      };
    };
  };
}
