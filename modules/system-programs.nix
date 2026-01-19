{ pkgs, ... }:

{
  ############################################
  # Shell / Core programs
  ############################################
  programs = {
    zsh.enable = true;
    firefox.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  ############################################
  # Virtualization (KVM / QEMU / Libvirt)
  ############################################
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [ "virbr0" ];

    qemu = {
      swtpm.enable = true;
      ovmf.enable = true;
    };
  };

  programs.dconf.enable = true;
}
