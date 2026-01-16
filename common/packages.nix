{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnumake
    wget
    coreutils
    lshw
    iwd

    # # Containers
    # docker
    # docker-compose
    # devpod

#     # Wayland tools
#     waybar
#     rofi
#     wl-clipboard

#     # CLI
#     eza
#     btop
#     bat
#     htop
#     fd
#     ripgrep
#     yazi

#     # Go
# #    go
# #    gopls

#     # Rust
# #    rustup
# #    rust-analyzer

#     # Nix
# #    nixd
# #    nil
# #    statix
# #    deadnix
# #    nixfmt-rfc-style
  ];
}
