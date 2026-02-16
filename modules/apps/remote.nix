# modules/apps/remote.nix
# Remote access tools (Anydesk, etc.)
# NOTE: This is a home-manager module that also configures system-level services
{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  config = lib.mkIf config.apps.remote.enable {
    # Install AnyDesk package for the user
    home.packages = with pkgs; [
      anydesk
    ];

    # Enable AnyDesk system service
    # This requires the system configuration to have the service enabled
    home.activation.warnAnydesk = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ! systemctl is-enabled anydesk.service >/dev/null 2>&1; then
        echo "⚠️  AnyDesk package installed but system service not enabled!"
        echo "   Add to your host configuration (hosts/your-host.nix):"
        echo "   services.anydesk.enable = true;"
      fi
    '';
  };
}
