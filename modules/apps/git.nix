# modules/apps/git.nix
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    # Nome e email agora em settings
    settings.user = {
      name = "Waldir Borba Junior";
      email = "wborbajr@gmail.com";
    };

    # Editor padrão
    settings.core.editor = "nvim";

    # Ignora global
    ignores = [
      "*.swp" "*.swo" "*.swn" "*~" ".fuse_hidden*"
      ".DS_Store"
      ".venv/" "venv/" "__pycache__/" "*.pyc"
      "node_modules/" ".npm/" ".yarn/" "dist/" "build/"
      ".terraform/" "*.tfstate" "*.tfstate.backup"
      ".kube/" "k8s/" "*.kubeconfig"
      ".direnv/" ".envrc"
      "*.log" "*.tmp" "*.bak"
      "tags" "TAGS" "cscope.*"
      ".env" ".env.local" ".env.*"
      ".cache/" ".pytest_cache/"
    ];
  };

  # Delta como pager separado (módulo próprio agora)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;  # ← obrigatório agora (resolve o warning)
    options = {
      side-by-side = true;
      line-numbers = true;
      navigate = true;
      theme = "Monokai Extended";  # mude se quiser outro tema
    };
  };

  # Configurações gerais e aliases (agora em settings.extraConfig ou direto em settings)
  programs.git.settings = {
    init.defaultBranch = "main";
    pull.rebase = true;
    push = {
      default = "current";
      autoSetupRemote = true;
    };
    fetch = {
      prune = true;
      pruneTags = true;
    };
    rebase = {
      autoStash = true;
      autoSquash = true;
    };
    merge.conflictStyle = "zdiff3";
    core.autocrlf = "input";

    alias = {
      # Básicos
      st   = "status --short --branch";
      co   = "checkout";
      br   = "branch -v";
      ci   = "commit";
      cm   = "commit -m";
      ca   = "commit --amend";
      lg   = "log --graph --oneline --decorate --all";
      df   = "diff --color-words";
      ds   = "diff --staged";
      fp   = "fetch --prune --prune-tags";
      pu   = "push --set-upstream origin HEAD";
      rh   = "reset --hard HEAD";
      undo = "reset --soft HEAD~1";

      # DevOps / Trabalho diário
      wip     = "commit -m 'WIP' --no-verify";
      fixup   = "commit --fixup=HEAD";
      squash  = "rebase -i --autosquash";
      amend   = "commit --amend --no-edit";
      last    = "log -1 --pretty=%B";
      who     = "shortlog -sn --since='1 week ago'";
      graph   = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      gone    = "!git fetch --prune && git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
      cleanup = "!git branch --merged main | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
      pr      = "!f() { git fetch origin pull/$1/head:pr/$1 && git checkout pr/$1; }; f";
      sync    = "!git fetch --prune && git rebase origin/$(git branch --show-current)";
      tags    = "tag --sort=-v:refname";
      remotes = "remote -v";
      fresh   = "fetch --all --prune && git pull --rebase";
      mr      = "merge --no-ff";
    };
  };

  # Pacotes relacionados
  home.packages = with pkgs; [
    git
    git-lfs
    delta
    tig
  ];
}
