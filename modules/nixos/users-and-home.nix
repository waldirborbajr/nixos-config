# modules/nixos/users-and-home.nix
#
# Shell padrão, usuário principal, greeter, wiring do home-manager e
# regra de sudo NOPASSWD. Extraído 1:1 de configuration.nix (split
# cirúrgico, sem mudança de comportamento).
{
  pkgs,
  pkgs-unstable,
  hostname,
  inputs,
  common,
  ...
}: let
  inherit (common) username;
in {
  # ==================== SHELL ====================
  programs.zsh.enable = true;

  # ==================== USERS ====================
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "borba jr, w";
    extraGroups = ["networkmanager" "wheel" "podman" "dialout"]; # dialout: cabo serial do CHIRP
    shell = pkgs.zsh;
  };

  users.users.greeter.extraGroups = ["video" "input" "render"];

  # ==================== HOME MANAGER ====================
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    extraSpecialArgs = {
      inherit inputs hostname pkgs-unstable;
    };

    users.${username} = import ../../home/default.nix;
  };

  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
