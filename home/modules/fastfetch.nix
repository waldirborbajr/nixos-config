# home/modules/fastfetch.nix
#
# MIGRAÇÃO (mesmo padrão de shell.nix/btop.nix/tmux.nix): antes era
# `home.packages = [ fastfetch ]` (em cli-and-terminal.nix) + xdg.configFile
# apontando pra home/configs/fastfetch/config.jsonc — na verdade dois
# donos pra mesma feature (o achado original: o pacote vivia em
# environment.systemPackages enquanto a config já estava linkada aqui).
# Agora é config nativa via programs.fastfetch.settings.
#
# home/configs/fastfetch.old/ guarda o original (renomeado, não apagado).
_: {
  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";

      logo = {
        type = "chafa";
        source = "/home/borba/Picture/logo.png";
        width = 30;
        height = 12;
      };

      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "wmtheme"
        "theme"
        "icons"
        "font"
        "cursor"
        "terminal"
        "terminalfont"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "localip"
        "battery"
        "poweradapter"
        "locale"
        "break"
        "colors"
      ];
    };
  };
}
