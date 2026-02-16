# modules/apps/dev-tools.nix
# GitHub CLI and development tools
# Git configuration moved to modules/apps/git.nix
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.dev-tools.enable {

    # ========================================
    # GitHub CLI
    # ========================================
    programs.gh = {
      enable = true;

      extensions = with pkgs; [
        gh-notify
        gh-poi
        gh-f
        gh-s
        gh-markdown-preview
      ];

      settings = {
        git_protocol = "ssh";
        editor = "";
        prompt = "enabled";
        prefer_editor_prompt = "disabled";
        pager = "";

        aliases = {
          co = "pr checkout";
          pv = "pr view --web";
          pi = "pr create --fill --web";
          il = "issue list --limit 20";
          ic = "issue create --web";
          prm = "pr merge --squash --delete-branch";
          prd = "pr merge --delete-branch";
          prr = "pr ready";
          prc = "pr checks";
          prs = "pr status";
          repo = "repo view --web";
          rcl = "repo clone";
          rl = "release list";
          rc = "release create --generate-notes";
          rw = "workflow list";
          rwr = "workflow run";
          auth = "auth status";
          who = "api user --jq '.login'";
          prl = "pr list --limit 20";
          draft = "pr create --draft --fill";
          review = "pr review --approve";
          "merge-auto" = "pr merge --auto --squash";
        };
      };
    };

    # ========================================
    # Core development packages
    # ========================================
    home.packages = with pkgs; [
      git-lfs
      tig
      gh-dash
      jujutsu # Modern VCS, compatible with Git
      just # Command runner (Make alternative)
    ];
  };
}
