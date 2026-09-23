# modules/user_borba.nix
#
# Shell padrão, usuário principal, greeter, opções base do home-manager
# e regra de sudo NOPASSWD.
#
# O wiring `home-manager.users.${username} = import .../home/<host>.nix`
# NÃO mora aqui — cada hosts/<host>/configuration.nix aponta pro próprio
# arquivo em home/, para que "qual home-manager este host usa" seja uma
# decisão local do host, não escondida num módulo compartilhado.
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
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "dialout"
    ]; # dialout: cabo serial do CHIRP
    shell = pkgs.zsh;
  };

  users.users.greeter.extraGroups = [
    "video"
    "input"
    "render"
  ];

  # ==================== HOME MANAGER ====================
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    extraSpecialArgs = {
      inherit inputs hostname pkgs-unstable;
    };
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
