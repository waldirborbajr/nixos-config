# home/modules/oh-my-posh.nix
#
# Prompt via oh-my-posh, integrado ao zsh (enableZshIntegration).
# Tema embutido a partir do antigo zen.toml (home/configs/oh-my-posh.old/).
#
# Relação com zsh:
#   programs.oh-my-posh.enableZshIntegration injeta
#   `eval "$(oh-my-posh init zsh --config …)"` no .zshrc gerado pelo HM.
#   programs.zsh (zsh.nix) já define VIRTUAL_ENV_DISABLE_PROMPT=1 para
#   não duplicar o venv no prompt.
#
# NÃO declarar oh-my-posh em cli-and-terminal.nix (package nem xdg).
{
  lib,
  config,
  ...
}: {
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
      version = 2;
      final_space = true;
      console_title_template = "{{ .Shell }} in {{ .Folder }}";

      blocks = [
        {
          type = "prompt";
          alignment = "left";
          newline = false;
          segments = [
            {
              type = "path";
              style = "plain";
              background = "transparent";
              foreground = "#8aadf4";
              template = "{{ .Path }}";
              properties = {
                style = "full";
              };
            }
            {
              type = "go";
              style = "plain";
              foreground = "#ffffff";
              background = "transparent";
              template = "  {{ .Full }} ";
              properties = {
                fetch_version = true;
                display_mode = "context";
              };
            }
            {
              type = "rust";
              style = "plain";
              foreground = "#193549";
              background = "transparent";
              template = "  {{ .Full }} ";
              properties = {
                fetch_version = true;
                display_mode = "context";
              };
            }
            {
              type = "python";
              style = "plain";
              background = "transparent";
              foreground = "#ffd43b";
              template = "  {{ .Full }} ";
              properties = {
                fetch_version = true;
                fetch_virtual_env = true;
                display_mode = "context";
              };
            }
            {
              type = "docker";
              style = "plain";
              background = "transparent";
              foreground = "#0db7ed";
              template = "  {{ .Context }} ";
              properties = {
                display_mode = "context";
                fetch_context = true;
              };
            }
            {
              type = "git";
              style = "plain";
              foreground = "#6e738d";
              background = "transparent";
              template = " {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>";
              properties = {
                branch_icon = "";
                commit_icon = "@";
                fetch_status = true;
              };
            }
          ];
        }
        {
          type = "rprompt";
          overflow = "hidden";
          segments = [
            {
              type = "executiontime";
              style = "plain";
              foreground = "#eed49f";
              background = "transparent";
              template = "{{ .FormattedMs }}";
              properties = {
                threshold = 5000;
              };
            }
          ];
        }
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "text";
              style = "plain";
              foreground_templates = [
                "{{if gt .Code 0}}#ed8796{{end}}"
                "{{if eq .Code 0}}#c6a0f6{{end}}"
              ];
              background = "transparent";
              template = "❯";
            }
          ];
        }
      ];

      transient_prompt = {
        foreground_templates = [
          "{{if gt .Code 0}}#ed8796{{end}}"
          "{{if eq .Code 0}}#c6a0f6{{end}}"
        ];
        background = "transparent";
        template = "❯ ";
      };

      secondary_prompt = {
        foreground = "#c6a0f6";
        background = "transparent";
        template = "❯❯ ";
      };
    };
  };

  # oh-my-posh cacheia o init com path absoluto do store —
  # limpar em toda ativação evita prompt quebrado após rebuild.
  home.activation.clearOhMyPoshCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD rm -rf "${config.xdg.cacheHome}/oh-my-posh"
  '';
}
