# home/modules/ripgrep.nix
#
# Config nativa via programs.ripgrep.arguments.
# O binário `ripgrep` em si vem de system/modules/dev.nix (ou package).
_: {
  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--fixed-strings"
    ];
  };
}
