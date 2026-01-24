# modules/apps/git.nix
{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    userName  = "Waldir Borba Junior";
    userEmail = "wborbajr@gmail.com";

    # Ignora arquivos globais (suportado nativamente)
    ignores = [
      "*.swp" "*.swo" "*.swn" ".DS_Store"
      ".venv/" "venv/" "node_modules/"
      ".terraform/" "*.tfstate*" ".direnv/" ".envrc"
      "*.log" "*.tmp" "*.bak" "tags" "TAGS"
      "__pycache__/" "*.pyc"
    ];
  };

  # Config avançada via ~/.config/git/config (declarativo e Nix-gerenciado)
  xdg.configFile."git/config".text = ''
    [core]
        editor = nvim
        pager = bat
        autocrlf = input

    [init]
        defaultBranch = main

    [pull]
        rebase = true

    [push]
        default = current
        autoSetupRemote = true

    [fetch]
        prune = true
        pruneTags = true

    [rebase]
        autoStash = true
        autoSquash = true

    [merge]
        conflictStyle = zdiff3

    # Aliases DevOps-friendly
    [alias]
        st = status --short --branch
        co = checkout
        br = branch -v
        ci = commit
        cm = commit -m
        ca = commit --amend
        lg = log --graph --oneline --decorate --all
        df = diff --color-words
        ds = diff --staged
        fp = fetch --prune --prune-tags
        pu = push --set-upstream origin HEAD
        rh = reset --hard HEAD
        undo = reset --soft HEAD~1
  '';

  # Pacotes relacionados
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    bat          # usado como pager
    delta        # diff bonito (opcional, mas recomendado)
    tig          # TUI git (opcional)
  ];
}
