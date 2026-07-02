{
  description = "borba's NixOS configuration";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
 nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
nixpkgs-stable.url,
    nixpkgs-unstable.url,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
      ];
    };
  };
}
