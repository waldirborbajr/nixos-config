{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.sqlite.enable {
    # SQLite é tratado como um ambiente de desenvolvimento independente,
    # assim como Rust, Go, Nix etc. Nada de SQLite fica no base.nix.
    environment.systemPackages = with pkgs; [
      sqlite
      sqlite-analyzer
    ];
  };
}
