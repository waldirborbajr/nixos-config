# modules/nixos/audio.nix
#
# PipeWire (substitui pulseaudio) + rtkit. Extraído 1:1 de
# configuration.nix (split cirúrgico, sem mudança de comportamento).
{...}: {
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
