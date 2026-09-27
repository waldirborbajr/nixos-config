# home/modules/atuin.nix
#
# MIGRAÇÃO (mesmo padrão de shell.nix/btop.nix/tmux.nix): antes era
# `home.packages = [ atuin ]` (em cli-and-terminal.nix) + xdg.configFile
# apontando pra home/configs/atuin/config.toml. Agora é config nativa
# via programs.atuin.settings.
#
# home/configs/atuin.old/ guarda o original (renomeado, não apagado).
#
# ACHADO ao migrar, precisa da sua decisão: o config.toml original tinha
#   auto_sync = true
#   sync_address = "https://atuin.internal.leomercier.dev"
# "leomercier.dev" não é seu domínio — isso mandaria seu histórico de
# shell (todo comando digitado, exceto o que history_filter exclui) pro
# servidor de sync de outra pessoa. Desliguei o auto_sync por segurança.
# Se isso for um servidor de sync self-hosted seu, me avisa que eu ligo
# de volta com o endereço certo.
_: {
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      auto_sync = false; # ver achado acima
      # sync_address = "https://SEU-SERVIDOR-AQUI";

      style = "compact";
      inline_height = 0;

      history_filter = [
        "^cd"
        "^clear"
        "^e"
        "^exit"
        "^htop"
        "^ls"
        "^rm"
        "^shred"
        "^z"
      ];

      enter_accept = true;
      theme.name = "catppuccin-mocha";
      ai.enabled = false;

      daemon = {
        enabled = false;
        autostart = false;
      };

      tmux = {
        enabled = true;
        width = "80%";
        height = "60%";
      };
    };
  };
}
