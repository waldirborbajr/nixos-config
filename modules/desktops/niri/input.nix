# modules/desktops/niri/input.nix
# Input configuration (keyboard, touchpad, mouse, etc)
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  
  inputConfig = ''
    // ============================================
    // INPUT CONFIGURATION
    // ============================================
    input {
      keyboard {
        xkb {
          layout "us"
          variant ""
        }
        repeat-delay 250
        repeat-rate 35
        track-layout "global"
      }

      touchpad {
        tap
        natural-scroll
        dwt
        dwtp
        accel-speed 0.3
        accel-profile "adaptive"
        scroll-method "two-finger"
        click-method "clickfinger"
      }

      mouse {
        accel-speed 0.0
        accel-profile "flat"
      }

      tablet {
        map-to-output "eDP-1"
      }

      touch {
        map-to-output "eDP-1"
      }

      trackpoint {
        accel-speed 0.2
        accel-profile "adaptive"
      }

      focus-follows-mouse
      workspace-auto-back-and-forth
    }
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/input.kdl".text = inputConfig;
}
