let
  unstablePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "3f64aad060184c7edcc42c501060752dba9369adc63b300ecab8030a46274de2";
  }) {
    config = { allowUnfree = true; };
  };
in
{
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (final: prev: {
        unstable = unstablePkgs;
      })
    ];
  };
}
