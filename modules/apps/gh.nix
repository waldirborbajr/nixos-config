# modules/apps/gh.nix
{ config, pkgs, lib, ... }:

{
  programs.gh = {
    enable = true;

    settings = {
      git_protocol = "https";  # default global
      editor = "";             # usa $EDITOR (nvim)
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      pager = "";              # usa $PAGER
    };

    # Aliases expandidos para DevOps (mantidos e úteis)
    aliases = {
      co  = "pr checkout";
      pv  = "pr view --web";
      pi  = "pr create --fill --web";
      il  = "issue list --limit 20";
      ic  = "issue create --web";
      prm = "pr merge --squash --delete-branch";
      prd = "pr merge --delete-branch";
      prr = "pr ready";
      prc = "pr checks";
      prs = "pr status";
      repo = "repo view --web";
      rcl = "repo clone";
      rl  = "release list";
      rc  = "release create --generate-notes";
      rw  = "workflow list";
      rwr = "workflow run";
      auth = "auth status";
      who  = "api user --jq '.login'";
      prl = "pr list --limit 20";
      draft = "pr create --draft --fill";
      review = "pr review --approve";
      merge-auto = "pr merge --auto --squash";
    };
  };

  home.packages = with pkgs; [
    gh
    gh-dash  # TUI para PRs/issues (opcional mas recomendado)
  ];

  # Opcional: ativação para configurar hosts múltiplos (só roda na primeira ativação)
  # Rode manualmente depois da primeira vez: gh auth login para cada host
  # Depois: gh config set user omnicwbdev --host github.com
  # gh config set user waldirborbajr --host gitlab.com
}
