# home/modules/yazi.nix
#
# MIGRAÇÃO (mesmo padrão de shell.nix/btop.nix/tmux.nix): antes era
# `programs.yazi.enable` (em cli-and-terminal.nix) + xdg.configFile
# apontando pra home/configs/yazi/yazi.toml. Agora é config nativa via
# programs.yazi.settings.
#
# home/configs/yazi.old/ guarda o original (renomeado, não apagado).
_: {
  programs.yazi = {
    enable = true;

    settings = {
      opener.edit = [
        {
          run = ''hx "$@"'';
          desc = "Helix";
          block = true;
          for = "unix";
        }
      ];

      open.rules = [
        {
          mime = "text/*";
          use = ["edit" "reveal"];
        }
        {
          mime = "application/json";
          use = ["edit" "reveal"];
        }
        {
          mime = "application/javascript";
          use = ["edit" "reveal"];
        }
        {
          mime = "application/xml";
          use = ["edit" "reveal"];
        }
        {
          mime = "application/x-yaml";
          use = ["edit" "reveal"];
        }
        {
          mime = "application/toml";
          use = ["edit" "reveal"];
        }
        {
          mime = "inode/x-empty";
          use = ["edit" "reveal"];
        }
        # Fallback: continua abrindo com Helix (Enter no arquivo)
        {
          url = "*";
          use = ["edit" "open" "reveal"];
        }
      ];
    };
  };
}
