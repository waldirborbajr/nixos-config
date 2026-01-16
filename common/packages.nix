# { pkgs, ... }:

# {
#   environment.systemPackages = with pkgs; [
#     gnumake
#     wget
#     coreutils
#     lshw
#     iwd

#   ];
# }

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ############################################
    # Core UNIX / Build
    ############################################
    coreutils
    gnumake
    wget
    curl
    gnupg

    ############################################
    # Hardware / System Debug
    ############################################
    lshw
    pciutils      # lspci
    usbutils      # lsusb
    lm_sensors    # sensores de temperatura

    ############################################
    # Network / Connectivity
    ############################################
    iwd
    iproute2      # ip
    iputils       # ping
    traceroute
    dnsutils      # dig, nslookup
    nmap          # diagnóstico de rede

    ############################################
    # Storage / Filesystem
    ############################################
    e2fsprogs     # fsck, tune2fs
    ntfs3g        # NTFS
    dosfstools    # FAT

    ############################################
    # Process / System inspection
    ############################################
    procps        # ps, top
    psmisc        # killall, fuser
    util-linux    # mount, lsblk, etc

    ############################################
    # Archive / Recovery
    ############################################
    unzip
    zip
    rsync
    file

    ############################################
    # Certificates / SSL
    ############################################
    cacert
  ];
}
