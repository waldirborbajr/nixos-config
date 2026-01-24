# modules/apps/gh.nix
{ config, pkgs, lib, ... }:

{
  programs.gh = {
    enable = true;

    # Configurações gerais (equivalente ao seu config.yml)
    settings = {
      version = 1;
      git_protocol = "https";
      editor = "";  # vazio = usa $EDITOR (nvim)
      prompt = "enabled";
      prefer_editor_prompt = "disabled";
      pager = "";   # vazio = usa $PAGER (bat se configurado)
    };

    # Hosts múltiplos (GitHub + GitLab)
    gitCredentialHelper.enable = true;
    extensions = [];  # se quiser gh-dash, gh-dash etc. depois

    # Hosts configurados
    extraConfig = {
      hosts = {
        "github.com" = {
          git_protocol = "ssh";
          users = {
            waldirborbajr = { };
            omnicwbdev = { };
          };
          user = "omnicwbdev";  # default para github.com
        };
        "gitlab.com" = {
          git_protocol = "ssh";
          users = {
            waldirborbajr = { };
            omnicwbdev = { };
          };
          user = "waldirborbajr";  # default para gitlab.com
        };
      };
    };

    # Aliases expandidos para DevOps (baseado no seu + mais úteis)
    aliases = {
      co   = "pr checkout";                        # checkout PR
      pv   = "pr view --web";                      # abre PR no browser
      pi   = "pr create --fill --web";             # cria PR preenchido + abre web
      il   = "issue list --limit 20";              # lista issues recentes
      ic   = "issue create --web";                 # cria issue no browser
      prm  = "pr merge --squash --delete-branch";  # merge squash + deleta branch
      prd  = "pr merge --delete-branch";           # merge default + deleta branch
      prr  = "pr ready";                           # marca PR como ready
      prc  = "pr checks";                          # mostra checks/CI do PR atual
      prs  = "pr status";                          # status de PRs/review requests
      repo = "repo view --web";                    # abre repo no browser
      rcl  = "repo clone";                         # clona repo (gh repo clone org/repo)
      rl   = "release list";                       # lista releases
      rc   = "release create --generate-notes";    # cria release com notes automáticas
      rw   = "workflow list";                      # lista GitHub Actions workflows
      rwr  = "workflow run";                       # roda workflow manual (ex: gh workflow run ci.yml)
      auth = "auth status";                        # status de autenticação
      who  = "api user --jq '.login'";             # mostra usuário atual logado
    };
  };

  # Pacotes relacionados (gh principal + úteis)
  home.packages = with pkgs; [
    gh
    gh-dash  # opcional: TUI bonito para PRs/issues (gh-dash)
  ];
}
