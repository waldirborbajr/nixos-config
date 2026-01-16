{ pkgs, ... }:

{
  home.packages = with pkgs; [
    devpod

    # Podman ecosystem
    podman
    podman-compose
    skopeo
    buildah
    cri-tools
  ];
}
