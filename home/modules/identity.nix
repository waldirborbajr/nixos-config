# home/modules/identity.nix
#
# Identidade do usuário Home Manager, nix-index-database e o índice de
# home.packages. Extraído 1:1 de home/default.nix (split cirúrgico, sem
# mudança de comportamento).
{...}: let
  username = "borba";
in {
  home.username = username;
  home.homeDirectory = "/home/${username}";

  xdg.enable = true;

  # nix-index-database: prebuilt weekly-updated index, so `command-not-found`
  # suggestions and `nix-locate` work instantly without running `nix-index`
  # by hand on every host. `comma` lets you run a command from a package
  # you haven't installed yet: `, cowsay`.
  programs.nix-index-database.comma.enable = true;

  # Pure-user packages can migrate here over time.
  home.packages = [];
}
