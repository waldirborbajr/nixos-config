# modules/apps/gh.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.gh ];

  xdg.configFile."gh/config.yml".text = ''
    version: 1
    git_protocol: https
    editor:
    prompt: enabled
    prefer_editor_prompt: disabled
    pager:
    aliases:
      co: pr checkout
      pv: pr view --web
      pi: pr create --fill --web
      il: issue list --limit 20
      ic: issue create --web
    hosts:
      github.com:
        git_protocol: ssh
        users:
          waldirborbajr: {}
          omnicwbdev: {}
        user: omnicwbdev
      gitlab.com:
        git_protocol: ssh
        users:
          waldirborbajr: {}
          omnicwbdev: {}
        user: waldirborbajr
  '';
}
