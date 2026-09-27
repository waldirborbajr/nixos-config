# home/modules/git.nix
#
# Git sob controle do Home Manager (programs.git.settings).
# Conteúdo do antigo home/configs/git/config embutido aqui —
# NÃO usar xdg.configFile."git" recursive junto (conflito com git/config).
{pkgs, ...}: {
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Waldir Borba Junior";
        email = "wborbajr@gmail.com";
        signingkey = "~/.ssh/id_ed25519.pub";
      };

      init.defaultBranch = "main";

      # gpg.format = "ssh";
      # commit.gpgsign = true;
      # tag.gpgsign = true;

      core = {
        # editor = "hx";
        pager = "delta";
      };

      interactive.diffFilter = "delta --color-only";

      delta = {
        features = "mellow-barbet";
        navigate = true;
      };

      pull.rebase = true;

      push.autoSetupRemote = true;

      # list branches by most recent commit
      branch.sort = "-committerdate";

      checkout.defaultRemote = "origin";

      # remove remote-tracking branches that no longer exist upstream
      fetch.prune = true;

      # reuse recorded conflict resolutions automatically
      rerere.enabled = true;

      # include the common ancestor in conflict markers for easier resolution
      merge.conflictStyle = "zdiff3";
    };

    includes = [
      {path = "~/.config/delta/themes.gitconfig";}
    ];
  };

  # delta + temas (se não estiverem noutro módulo)
  home.packages = [pkgs.delta];
}
