# home/modules/ripgrep.nix
#
# Dono único do ripgrep (pacote + config): tem config própria
# (programs.ripgrep.arguments), por isso mora no home-manager, não em
# system/profiles/base.nix nem em system/modules/dev.nix.
_: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--fixed-strings"
    ];
  };
}
