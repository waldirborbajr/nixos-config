{ pkgs, ... }:

{
  home.packages = with pkgs; [
    chromium
    firefox-devedition
    brave
  ];

  ####################
  # Firefox Developer Edition
  ####################
#   programs.firefox = {
#     enable = true;

#     package = pkgs.firefox-devedition;

#     profiles.dev = {
#       isDefault = true;

#       settings = {
#         # Performance / Dev
#         "browser.tabs.remote.autostart" = true;
#         "browser.cache.disk.enable" = true;
#         "browser.sessionstore.interval" = 30000;

#         # UX dev
#         "devtools.theme" = "dark";
#         "devtools.toolbox.host" = "bottom";

#         # Telemetria OFF
#         "toolkit.telemetry.enabled" = false;
#         "toolkit.telemetry.unified" = false;
#         "browser.ping-centre.telemetry" = false;
#         "datareporting.healthreport.uploadEnabled" = false;
#       };
#     };
#   };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;

    profiles.dev = {
      isDefault = true;

      settings = {
        #### Wayland ####
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "widget.wayland-dmabuf-vaapi.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;

        #### Performance ####
        "layers.acceleration.force-enabled" = true;
        "gfx.x11-egl.force-enabled" = false;
        "gfx.webrender.compositor" = true;

        #### Input / UX ####
        "apz.gtk.kinetic_scroll.enabled" = true;
        "general.smoothScroll" = true;

        #### Telemetria OFF ####
        "toolkit.telemetry.enabled" = false;
      };
    };
  };

  #### ENV GLOBAL (Firefox respeita)
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };
  
}
