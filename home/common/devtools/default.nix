{ pkgs, ... }:

{
  imports = [
    ./go/default.nix
    ./rust/default.nix
    ./nix/default.nix
    ./neovim/default.nix
    ./docker/default.nix
  ];

}

