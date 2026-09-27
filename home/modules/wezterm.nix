# home/modules/wezterm.nix
#
# WezTerm sob home-manager. Config real fica em home/configs/wezterm/
# (wezterm.lua já resolve Linux x86_64 vs macOS M2 sozinho via
# wezterm.target_triple — sem branch por OS aqui). NÃO importado em
# nenhum profile: o terminal padrão continua Alacritty
# (home/modules/alacritty.nix / cli-and-terminal.nix). Fica pronto pra
# adotar quando/se quiser — é só importar este arquivo em
# home/profiles/base.nix ou desktop.nix.
_: {
  programs.wezterm.enable = true; # só instala o pacote — config vem do link abaixo

  # Dotfiles crus linkados inteiros: wezterm.lua, .luarc.json (lua_ls),
  # stylua.toml (formatter) e colors/dank-theme.toml (color scheme
  # custom, referenciável em config.color_scheme). Não usa
  # programs.wezterm.extraConfig pra não duplicar/colidir com este link.
  xdg.configFile."wezterm" = {
    source = ../configs/wezterm;
    recursive = true;
  };
}
