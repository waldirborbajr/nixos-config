# Trecho pra colar em home/profiles/base.nix (substituir o bloco Git).
#
# programs.git.enable escreve ~/.config/git/config e COLIDE com
# xdg.configFile."git" = { recursive = true; }.
# Enquanto a config continuar linkada do diretório, instale só o binário.

  # ── Git ─────────────────────────────────────────────────────────────
  # Config linkada via xdg (home/configs/git/). NÃO usar programs.git.enable
  # junto — o módulo escreve git/config e conflita com o recursive symlink.
  home.packages = [ pkgs.git ];
  xdg.configFile."git" = {
    source = "${configs}/git";
    recursive = true;
  };
