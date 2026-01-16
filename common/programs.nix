{ pkgs, ... }:

{
  programs = {
    nm-applet.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
  };
}
