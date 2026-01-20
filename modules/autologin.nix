{ ... }:
{
  services.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
}
