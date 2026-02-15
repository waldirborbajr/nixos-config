# modules/apps/git.nix
# Git version control system configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.git.enable {
    programs.git = {
      enable = true;

      settings = {
        user = {
          name = "waldirborbajr";
          email = "wborbajr@gmail.com";
        };

        core = {
          editor = "nvim";
          autocrlf = "input";
        };

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
        
        url."git@github.com:waldirborbajr/".insteadOf = "fp:";

        alias = {
          st = "status --short --branch";
          co = "checkout";
          br = "branch -v";
          ci = "commit";
          cm = "commit -m";
          ca = "commit --amend";
          lg = "log --graph --oneline --decorate --all";
          df = "diff --color-words";
          ds = "diff --staged";
          fp = "fetch --prune --prune-tags";
          pu = "push --set-upstream origin HEAD";
          rh = "reset --hard HEAD";
          undo = "reset --soft HEAD~1";
          wip = "commit -m 'WIP' --no-verify";
          fixup = "commit --fixup=HEAD";
          squash = "rebase -i --autosquash";
          amend = "commit --amend --no-edit";
          last = "log -1 --pretty=%B";
          who = "shortlog -sn --since='1 week ago'";
          graph = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          gone = "!git fetch --prune && git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
          cleanup = "!git branch --merged main | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
          pr = "!f() { git fetch origin pull/$1/head:pr/$1 && git checkout pr/$1; }; f";
          sync = "!git fetch --prune && git rebase origin/$(git branch --show-current)";
          tags = "tag --sort=-v:refname";
          remotes = "remote -v";
          fresh = "fetch --all --prune && git pull --rebase";
          mr = "merge --no-ff";
          cz = "!cz commit";
          czc = "!cz commit";
        };
      };

      ignores = [
        "*.swp"
        "*.swo"
        "*.swn"
        "*~"
        ".fuse_hidden*"
        ".DS_Store"
        ".venv/"
        "venv/"
        "__pycache__/"
        "*.pyc"
        "node_modules/"
        ".npm/"
        ".yarn/"
        "dist/"
        "build/"
        ".terraform/"
        "*.tfstate"
        "*.tfstate.backup"
        ".kube/"
        "k8s/"
        "*.kubeconfig"
        ".direnv/"
        ".envrc"
        "*.log"
        "*.tmp"
        "*.bak"
        "tags"
        "TAGS"
        "cscope.*"
        ".env"
        ".env.local"
        ".env.*"
        ".cache/"
        ".pytest_cache/"
      ];
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        side-by-side = true;
        line-numbers = true;
        navigate = true;
      };
    };
  };
}
