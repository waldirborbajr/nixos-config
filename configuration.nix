{
  config,
  pkgs,
  pkgs-unstable,
  hostname,
  lib,
  ...
}: let
  username = "borba";

  dotfilesDir = "/home/${username}/dotfiles";
  dotfileConfigDir = "/home/${username}/.config";

  common = {
    inherit username dotfilesDir dotfileConfigDir;
  };

  dotfilePrograms = [
    "tmux"
    "alacritty"
    "i3"
    "i3status"
    "rofi"
    "oh-my-posh"
    "helix"
    "git"
  ];

  mkDotfileLink = name:
    "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  _module.args.common = common;

  imports = [
    # sops-nix já vem do flake
  ];

  # ==================== KERNEL ====================
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==================== DOTFILES ====================
  systemd.tmpfiles.rules =
    (map mkDotfileLink dotfilePrograms)
    ++ [
      "L+ /home/${username}/.zshenv - - - - ${dotfilesDir}/zsh/.zshenv"
      "L+ /home/${username}/.config/zsh - - - - ${dotfilesDir}/zsh/.config/zsh"
    ];

  # ==================== HOST ====================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

  # ==================== LOCALE ====================
  i18n.defaultLocale = "en_US.UTF-8";

  # ==================== USERS ====================
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "borba jr, w";
    extraGroups = ["networkmanager" "wheel"];
  };

  security.sudo.extraRules = [
    {
      users = [username];
      commands = [{
        command = "ALL";
        options = ["NOPASSWD"];
      }];
    }
  ];

  # ==================== SSH (HOST KEY VIA SOPS) ====================

  sops = {
    defaultSopsFile = ./secrets/${hostname}.yaml;

    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    validateSopsFiles = false;
  };

  sops.secrets."ssh_host_ed25519_key" = {
    path = "/etc/ssh/ssh_host_ed25519_key";
    owner = "root";
    mode = "0600";
  };

  services.openssh = {
    enable = true;

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [22];

  # ==================== X11 + i3 ====================
  services.xserver.enable = true;

  services.xserver.windowManager.i3.enable = true;

  services.displayManager.defaultSession = "none+i3";

  # ==================== AUDIO ====================
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # ==================== PACKAGES ====================
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    (with pkgs; [
      wget curl git helix tmux bat ripgrep eza btop htop fastfetch
      alacritty zsh nixd alejandra rofi feh picom xclip
    ])
    ++ (with pkgs-unstable; [
      neovim
    ]);

  nix.settings.experimental-features = ["nix-command" "flakes"];

  system.stateVersion = "26.05";
}
