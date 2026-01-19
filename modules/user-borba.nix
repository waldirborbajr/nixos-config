{ pkgs, ... }:

{
  ############################################
  # User: borba
  ############################################
  users.users.borba = {
    isNormalUser = true;
    description = "BORBA JR W";

    # Default shell
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "libvirtd"
      "dialout"   # required for CHIRP / serial radios
    ];
  };

  ############################################
  # Zsh shell initialization for user
  ############################################
  programs.zsh = {
    enable = true;

    shellInit = ''
      # Clipboard alias (Wayland/X11)
      if command -v wl-copy &>/dev/null && [ -n "$WAYLAND_DISPLAY" ]; then
        alias clip='wl-copy'
        alias paste='wl-paste'
      elif command -v xclip &>/dev/null && [ -n "$DISPLAY" ]; then
        alias clip='xclip -selection clipboard'
        alias paste='xclip -selection clipboard -o'
      fi
    '';
  };

  ############################################
  # Auto-login
  ############################################
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  ############################################
  # Disable TTY competition
  ############################################
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ############################################
  # Passwordless sudo
  ############################################
  security.sudo.extraRules = [
    {
      users = [ "borba" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
