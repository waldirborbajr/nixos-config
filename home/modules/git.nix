# home/modules/git.nix
#
# Ecossistema git sob Home Manager:
#   git, delta, gh, gh-dash, lazygit, git-lfs, git-absorb, git-filter-repo
#
# NÃO declarar estes pacotes/programas noutro módulo (base.nix,
# cli-and-terminal.nix, etc.) — evita duplicata e conflito de config.
{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Waldir Borba Junior";
        email = "wborbajr@gmail.com";
        signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
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
      branch.sort = "-committerdate";
      checkout.defaultRemote = "origin";
      fetch.prune = true;
      rerere.enabled = true;
      merge.conflictStyle = "zdiff3";
    };

    includes = [
      {path = "${config.xdg.configHome}/delta/themes.gitconfig";}
    ];
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # LazyGit TUI (config migrada de home/configs/lazygit/config.yaml)
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = ["#cba6f7" "bold"];
          inactiveBorderColor = ["#a6adc8"];
          optionsTextColor = ["#89b4fa"];
          selectedLineBgColor = ["#313244"];
          cherryPickedCommitBgColor = ["#45475a"];
          cherryPickedCommitFgColor = ["#cba6f7"];
          unstagedChangesColor = ["#f38ba8"];
          defaultFgColor = ["#cdd6f4"];
          searchingActiveBorderColor = ["#f9e2af"];
        };
        authorColors = {
          "*" = "#b4befe";
        };
      };
      quitOnTopLevelReturn = true;
      disableStartupPopups = true;
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=never --line-numbers --hunk-header-style=\"file omit-code-fragment\" --file-style=\"omit\" --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          }
        ];
      };
    };
  };

  home.packages = with pkgs; [
    delta
    gh-dash
    git-lfs
    git-absorb
    git-filter-repo
  ];
}
