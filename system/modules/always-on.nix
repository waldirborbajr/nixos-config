# system/modules/always-on.nix
#
# Manter o host ligado: toggle development-style, default OFF.
#   power.alwaysOn.enable = true;   -> não suspende, não hiberna, ignora tampa
#   power.alwaysOn.enable = false;  -> comportamento normal de notebook
{
  config,
  lib,
  ...
}: let
  cfg = config.power.alwaysOn;
in {
  options.power.alwaysOn.enable =
    lib.mkEnableOption "manter o host sempre ligado (sem suspend/hibernate, tampa ignorada)";

  config = lib.mkIf cfg.enable {
    # Mascara os alvos de sleep: nenhum caminho (systemctl suspend, swayidle,
    # tampa, botão de energia configurado) consegue suspender o host.
    systemd.targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
      suspend-then-hibernate.enable = false;
    };

    # Tampa fechada não desliga nem suspende.
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };
}
