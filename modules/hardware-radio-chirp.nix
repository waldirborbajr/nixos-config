{ config, pkgs, ... }:

{
  ############################################
  # Disable brltty (conflicts with CHIRP)
  ############################################
  services.brltty.enable = false;
}
