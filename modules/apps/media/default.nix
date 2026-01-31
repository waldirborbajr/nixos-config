# modules/apps/media/default.nix
# Media tools aggregator - Dendritic Pattern
{ config, lib, ... }:

{
  imports = [
    ./image.nix
    ./audio.nix
    ./video.nix
    ./torrents.nix
  ];

  options.apps.media = {
    # Single enable for all media tools (backward compatibility)
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable all media tools (image, audio, video, torrents)";
    };

    # Granular controls
    image = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.media.enable;
        description = "Enable image editing tools (GIMP, Inkscape, ImageMagick)";
      };
    };

    audio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.media.enable;
        description = "Enable audio editing and playback tools (Audacity, MPV)";
      };
    };

    video = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.media.enable;
        description = "Enable video editing and conversion tools (Handbrake)";
      };
    };

    torrents = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.media.enable;
        description = "Enable BitTorrent clients (Transmission)";
      };
    };
  };
}
