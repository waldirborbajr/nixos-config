{...}: let
  username = "borba";

  # Shared values for host modules (username mainly).
  # Dotfile contents now live inside the flake under home/configs/ (fase 3).
  common = {
    inherit username;
  };
in {
  _module.args.common = common;

  imports = [
    # hardware-configuration.nix is imported per-host via flake.nix

    ./modules/nixos/system-base.nix
    ./modules/nixos/fonts.nix
    ./modules/nixos/users-and-home.nix
    ./modules/nixos/desktop-niri.nix
    ./modules/nixos/audio.nix
    ./modules/nixos/hardware-quirks.nix
    ./modules/nixos/packages.nix
    ./modules/nixos/ssh.nix
    ./modules/nixos/sops.nix
  ];

  # ==================== STATE VERSION ====================
  system.stateVersion = "26.05";
}
