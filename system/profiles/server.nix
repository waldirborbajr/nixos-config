# system/profiles/server.nix
#
# Perfil pra host headless — nenhum host seu hoje é servidor (os 4 hosts
# NixOS são todos desktops com sessão niri), então isso ainda não é
# importado em lugar nenhum. Existe pra bater com a estrutura
# (system/profiles/{base,desktop,server}.nix) e já vem com o padrão
# genérico de resiliência do ulyssecrn (log cap + reboot em kernel
# panic), que não é nada específico da frota dele.
{options, ...}: {
  # ==================== LOGGING ====================
  # Limita o tamanho do journal — host de longa duração não devia
  # encher o disco de log.
  services.journald =
    if options.services.journald ? settings
    then {
      settings.Journal = {
        SystemMaxUse = "500M";
        SystemMaxFileSize = "50M";
      };
    }
    else {
      extraConfig = ''
        SystemMaxUse=500M
        SystemMaxFileSize=50M
      '';
    };

  # ==================== RESILIENCE ====================
  # Host headless: reinicia sozinho em kernel panic, pra se recuperar
  # sem alguém precisar ir lá apertar um botão.
  boot.kernel.sysctl = {
    "kernel.panic" = 10;
    "kernel.panic_on_oops" = 1;
  };
}
