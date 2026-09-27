# home/modules/kitty.nix
#
# Estrutura herdada de github.com/ulyssecrn/nixos-config
# (home/modules/kitty.nix) — você pediu pra herdar a estrutura dele,
# não pra trocar de terminal. NÃO importado em nenhum profile: o
# terminal padrão continua Alacritty (home/modules/cli-and-terminal.nix).
# Fica pronto pra você adotar o kitty quando/se quiser — é só importar
# este arquivo em home/profiles/base.nix ou desktop.nix.
_: {
  programs.kitty = {
    enable = true;
    settings = {
      window_margin_width = "3 5 3";
      confirm_os_window_close = "0";
      copy_on_select = "yes"; # selecionar texto já copia pro clipboard
    };
  };
}
