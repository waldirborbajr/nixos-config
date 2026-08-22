# modules/nixos/system-base.nix
#
# Kernel, tmpfiles (ssh dir + regreet), política de sleep,
# segurança/sessão, rede e timezone/locale. Base comum a todos os hosts.
# Extraído 1:1 de configuration.nix (split cirúrgico, sem mudança de
# comportamento).
{
  pkgs,
  hostname,
  common,
  ...
}: let
  inherit (common) username;
  sshKeysDir = "/home/${username}/.ssh";
in {
  # ==================== KERNEL ====================
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==================== SSH KEY DIR + REGREET DIRS (tmpfiles) ====================
  systemd.tmpfiles.rules = [
    "d ${sshKeysDir} 0700 ${username} users -"
    "d /var/log/regreet 0755 greeter greeter -"
    "d /var/cache/regreet 0755 greeter greeter -"
    "d /var/lib/regreet 0755 greeter greeter -"
  ];

  # ==================== SLEEP POLICY ====================
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
    MemorySleepMode = "s2idle";
  };

  # ==================== SECURITY / SESSION ====================
  security.polkit.enable = true;
  security.soteria.enable = true;
  security.pam.services.swaylock = {};
  services.gnome.gnome-keyring.enable = true;

  # ==================== NETWORK ====================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  # ==================== TIME / LOCALE ====================
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
}
