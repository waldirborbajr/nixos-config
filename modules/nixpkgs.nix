{ lib, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };

    overlays = [
      (final: prev: {
        unstable = import <nixpkgs-unstable> {
          config.allowUnfree = true;
        };
      })
    ];
  };
}
