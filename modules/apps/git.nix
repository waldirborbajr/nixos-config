# modules/git.nix
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName  = "Waldir Borba Junior";
    userEmail = "wborbajr@gmail.com";

    # Editor padrão (já temos no sessionVariables, mas reforçando)
    extraConfig = {
      core = {
        editor = "nvim";
        pager  = "bat";               # usa bat como pager (bonito + syntax highlight)
        autocrlf = "input";           # padrão seguro para Linux/macOS
      };

      init = {
        defaultBranch = "main";
      };

      pull = {
        rebase = true;                # pull --rebase por padrão (evita merges desnecessários)
      };

      # Melhorias DevOps / workflow
      push = {
        default = "current";          # push só o branch atual (mais seguro)
        autoSetupRemote = true;       # git push cria upstream automaticamente
      };

      fetch = {
        prune = true;                 # remove branches deletadas remotamente
        pruneTags = true;
      };

      rebase = {
        autoStash = true;             # stash automático durante rebase
        autoSquash = true;
      };

      merge = {
        conflictStyle = "zdiff3";     # melhor visualização de conflitos (3-way)
      };

      # Aliases úteis para DevOps (curtos e práticos)
      alias = {
        st    = "status --short --branch";
        co    = "checkout";
        br    = "branch -v";
        ci    = "commit";
        cm    = "commit -m";
        ca    = "commit --amend";
        lg    = "log --graph --oneline --decorate --all";
        lga   = "log --graph --oneline --decorate --all --author-date-order";
        df    = "diff --color-words";
        ds    = "diff --staged";
        fp    = "fetch --prune --prune-tags";
        pu    = "push --set-upstream origin HEAD";   # push + cria upstream se não existir
        rh    = "reset --hard HEAD";                 # reset hard (cuidado!)
        undo  = "reset --soft HEAD~1";               # desfaz último commit mantendo changes
      };
    };

    # Ignorar arquivos comuns em DevOps
    ignores = [
      "*.swp" "*.swo" "*.swn"          # vim swap
      ".DS_Store"                      # macOS
      "node_modules/"                  # JS
      ".direnv/" ".envrc"              # direnv
      ".venv/" "venv/"                 # python
      "*.log" "*.tmp" "*.bak"          # logs e temporários
      "tags" "TAGS"                    # ctags
      ".terraform/" "*.tfstate*"       # terraform
      "k8s/" ".kube/"                  # kubernetes local
    ];
  };

  # Pacotes relacionados (gh já vem abaixo)
  environment.systemPackages = with pkgs; [
    git
    git-lfs               # se precisar de large files
    delta                 # melhor visualizador de diff (opcional, mas muito bom)
    tig                   # terminal git UI (opcional)
  ];

  # Opcional: delta como pager padrão (mais bonito que bat para diffs)
  # Se quiser usar delta em vez de bat para git diff:
  # environment.variables = {
  #   GIT_PAGER = "delta";
  # };
}
