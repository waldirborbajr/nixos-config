{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.nix.enable {
    # Nix language tooling: language servers and formatter.
    # These are intentionally kept out of the global NixOS package set.
    environment.systemPackages = with pkgs; [
      nixd
      nil
      alejandra
    ];
  };
}
