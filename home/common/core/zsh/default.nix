{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    ############################################
    # Plugins (forma correta no Home Manager)
    ############################################
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
    ];

    ############################################
    # Aliases
    ############################################
    shellAliases = {
      ff = "fastfetch";

      # git
      gaa = "git add --all";
      gcam = "git commit --all --message";
      gcl = "git clone";
      gco = "git checkout";
      ggl = "git pull";
      ggp = "git push";

      # kubectl
      k = "kubectl";
      kctx = "kubectx";
      kgno = "kubectl get node";

      # tools
      lg = "lazygit";
      pt = "podman-tui";

      # navigation
      repo = "cd $HOME/Documents/repositories";
      temp = "cd $HOME/Downloads/temp";

      # editor
      v = "nvim";
      vi = "nvim";
      vim = "nvim";

      # eza
      ls = "eza --icons always";
      ll = "eza -bhl --icons --group-directories-first";
      la = "eza -abhl --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";
    };

    ############################################
    # Init
    ############################################
    initContent = ''
      # kubectl auto-complete (incluindo alias k)
      source <(kubectl completion zsh)
      complete -o default -F __start_kubectl k

      # keybindings
      bindkey -e
      bindkey '^H' backward-delete-word
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      # open command line in $EDITOR with C-v
      autoload -z edit-command-line
      zle -N edit-command-line
      bindkey '^v' edit-command-line
    ''
    + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      # Enable ALT-C fzf keybinding on macOS
      bindkey 'ć' fzf-cd-widget
    '';
  };
}
