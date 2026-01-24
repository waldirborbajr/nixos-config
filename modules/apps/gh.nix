# modules/gh.nix
{ config, pkgs, lib, ... }:

let
  ghConfig = {
    version = 1;
    git_protocol = "https";  # default global
    editor = "";
    prompt = "enabled";
    prefer_editor_prompt = "disabled";
    pager = "";
    aliases.co = "pr checkout";
    http_unix_socket = "";
    browser = "";
    color_labels = "disabled";
    accessible_colors = "disabled";
    accessible_prompter = "disabled";
    spinner = "enabled";
  };

  ghHosts = {
    "github.com" = {
      git_protocol = "ssh";
      users = {
        waldirborbajr = { };
        omnicwbdev = { };
      };
      user = "omnicwbdev";
    };

    "gitlab.com" = {
      git_protocol = "ssh";
      users = {
        waldirborbajr = { };
        omnicwbdev = { };
      };
      user = "waldirborbajr";  # ou o que preferir como default no gitlab
    };
  };
in
{
  programs.gh = {
    enable = true;
    enableGitCredentialHelper = true;  # integra com git credential
    settings = ghConfig // {
      hosts = ghHosts;
    };
  };

  # Pacote gh
  environment.systemPackages = with pkgs; [ gh ];

  # Opcional: alias global para gh (se quiser)
  environment.shellAliases = {
    ghpr = "gh pr create --fill --web";  # cria PR rápido
    ghv  = "gh pr view --web";           # abre PR no browser
    ghi  = "gh issue create --web";      # cria issue
  };
}
