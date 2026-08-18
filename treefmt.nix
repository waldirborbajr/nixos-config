{...}: {
  projectRootFile = "flake.nix";

  # .nix files — alejandra, same formatter already shipped in
  # environment.systemPackages, so `nix fmt` matches what you'd get
  # running it by hand.
  programs.alejandra.enable = true;
}
