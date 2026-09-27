# home/modules/jujutsu.nix
#
# Jujutsu sob controle do Home Manager (programs.jujutsu.settings).
# Conteúdo do antigo home/configs/jujutsu/jujutsu.toml embutido aqui —
# NÃO usar xdg.configFile."jj/config.toml" junto (conflito).
{pkgs, ...}: {
  programs.jujutsu = {
    enable = true;

    settings = {
      user = {
        email = "wborbajr@gmail.com";
        name = "BORBA W, JR";
      };

      signing = {
        backend = "gpg";
        behavior = "own";
      };

      aliases = {
        b = ["branch"];
        n = ["new"];
        # Move the closest bookmark to the current commit.
        tug = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"];
        # Rebase the current branch onto the trunk.
        retrunk = ["rebase" "-d" "trunk()"];
      };

      revset-aliases = {
        "closest_bookmark(to)" = "heads(::to & bookmarks())";
        "fork_history(to, from)" = "fork_point(to | from)..@";
      };

      template-aliases = {
        "format_timestamp(timestamp)" = "timestamp.ago()";
      };

      ui = {
        default-command = "log";
      };
    };
  };

  # lazyjj TUI (opcional — estava em cli-and-terminal.nix)
  home.packages = [pkgs.lazyjj];
}
