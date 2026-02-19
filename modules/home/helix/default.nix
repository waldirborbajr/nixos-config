{ config, pkgs, lib, ... }:

let
  removeTrailingWhitespaceFormatter = {
    command = "sed";
    args = [ "s/[[:space:]]*$//" ];
  };
in
{
  config = lib.mkIf config.apps.helix.enable {
    home.packages = with pkgs; [ helix ];
    programs.helix = {
      enable = true;
      settings = {
        editor = {
          true-color = true;
          bufferline = "multiple";
          line-number = "relative";
          lsp = {
            display-inlay-hints = true;
            display-messages = true;
          };
          search = { wrap-around = false; };
          soft-wrap = { enable = true; };
          auto-format = true;
          auto-pairs = {
            "(" = ")";
            "{" = "}";
            "[" = "]";
          };
        };
        keys = {
          normal = { "X" = [ "extend_line_up" "extend_to_line_bounds" ]; };
          insert = {
            up = "no_op";
            down = "no_op";
            left = "no_op";
            right = "no_op";
            pageup = "no_op";
            pagedown = "no_op";
            home = "no_op";
            end = "no_op";
          };
        };
      };
      languages = {
        language = [
          {
            name = "nix";
            language-servers = [ "nil" ];
            formatter = { command = "nixpkgs-fmt"; };
            auto-format = true;
          }
          {
            name = "rust";
            formatter = { command = "rustfmt"; args = [ "--edition=2021" ]; };
            auto-format = true;
          }
          {
            name = "go";
            auto-format = true;
          }
        ];
        language-server = {
          nil = { command = "nil"; };
        };
      };
    };
  };
}
# modules/apps/helix.nix
# Helix editor
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.helix.enable {
    home.packages = with pkgs; [
      helix
    ];
  };
}
