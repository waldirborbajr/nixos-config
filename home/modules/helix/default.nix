# home/modules/helix/default.nix
#
# Helix configuration managed natively by Home Manager/Nix.
# The previous home/configs/helix/config.toml and languages.toml are now
# represented directly as Nix attributes, following the structure used by
# Misterio77/Foundry.
{pkgs, ...}: let
  pkill =
    if pkgs.stdenv.isLinux
    then "${pkgs.procps}/bin/pkill"
    else "/usr/bin/pkill";
in {
  home.sessionVariables.EDITOR = "hx";
  home.sessionVariables.COLORTERM = "truecolor";

  programs.helix = {
    enable = true;
    package = pkgs.helix;

    settings = {
      theme = "nord";

      editor = {
        true-color = true;
        auto-format = true;
        bufferline = "multiple";
        mouse = true;
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        idle-timeout = 50;
        scroll-lines = 3;
        scrolloff = 8;
        text-width = 100;
        gutters = [
          "diff"
          "diagnostics"
          "line-numbers"
          "spacer"
        ];
        end-of-line-diagnostics = "hint";
        trim-trailing-whitespace = true;
        trim-final-newlines = true;
        continue-comments = false;
        completion-trigger-len = 1;
        completion-replace = true;

        auto-save = {
          focus-lost = true;
          after-delay = {
            enable = true;
            timeout = 1500;
          };
        };

        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "warning";
        };

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
          ];
          center = [
            "file-base-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "primary-selection-length"
            "position-percentage"
            "position"
            "total-line-numbers"
            "file-encoding"
            "file-type"
          ];
          separator = "│";
        };

        lsp = {
          enable = true;
          display-messages = true;
          display-inlay-hints = true;
          snippets = true;
          auto-signature-help = true;
          goto-reference-include-declaration = true;
        };

        soft-wrap = {
          enable = true;
          max-wrap = 25;
          max-indent-retain = 0;
          wrap-indicator = "↪ ";
        };

        indent-guides = {
          render = true;
          character = "▏";
        };

        file-picker = {
          hidden = true;
          parents = true;
          git-ignore = true;
          git-global = true;
          git-exclude = true;
        };
      };

      keys.normal = {
        U = "redo";

        "C-g" = [
          ":new"
          ":insert-output lazygit"
          ":buffer-close!"
          ":redraw"
          ":reload-all"
        ];

        "C-y" = [
          ":sh rm -f /tmp/helix-yazi-chooser"
          ":insert-output yazi %{buffer_name} --chooser-file=/tmp/helix-yazi-chooser"
          ":open %sh{cat /tmp/helix-yazi-chooser}"
          ":redraw"
        ];
      };
    };

    languages = {
      language-server = {
        llm-suggest.command = "llm-suggest-lsp";
        colors.command = "uwu-colors";
        scls.command = "simple-completion-language-server";

        gopls = {
          command = "gopls";
          config = {
            gofumpt = true;
            staticcheck = true;
            semanticTokens = true;
            usePlaceholders = true;
            completeUnimported = true;
            vulncheck = "Imports";
            hints = {
              compositeLiteralFields = true;
              parameterNames = true;
              rangeVariableTypes = true;
            };
          };
        };

        golangci-lint-lsp.command = "golangci-lint-langserver";

        rust-analyzer = {
          command = "rust-analyzer";
          config = {
            checkOnSave = true;
            check.command = "clippy";
            cargo.allFeatures = true;
            procMacro.enable = true;
            files.excludeDirs = [
              ".git"
              "target"
              "node_modules"
            ];
            inlayHints = {
              enable = true;
              parameterHints.enable = true;
              typeHints.enable = true;
              chainingHints.enable = true;
              closureReturnTypeHints.enable = "with_block";
            };
          };
        };

        lua-language-server.command = "lua-language-server";

        typescript-language-server = {
          command = "typescript-language-server";
          args = ["--stdio"];
        };

        pylsp.command = "pylsp";
        nixd.command = "nixd";
        nil.command = "nil";

        taplo = {
          command = "taplo";
          args = ["lsp" "stdio"];
        };

        vscode-json-language-server = {
          command = "vscode-json-language-server";
          args = ["--stdio"];
        };
      };

      language = [
        {
          name = "go";
          scope = "source.go";
          file-types = ["go"];
          roots = ["go.work" "go.mod"];
          auto-format = true;
          formatter = {
            command = "goimports";
            args = ["-"];
          };
          language-servers = [
            "gopls"
            "golangci-lint-lsp"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 4;
            unit = "\t";
          };
        }

        {
          name = "rust";
          scope = "source.rust";
          file-types = ["rs"];
          roots = ["Cargo.toml"];
          auto-format = true;
          formatter = {
            command = "rustfmt";
            args = ["--emit=stdout"];
          };
          language-servers = [
            "rust-analyzer"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 4;
            unit = "\t";
          };
        }

        {
          name = "lua";
          scope = "source.lua";
          file-types = ["lua"];
          roots = ["init.lua" ".luarc.json"];
          auto-format = true;
          formatter = {
            command = "stylua";
            args = ["--stdin-filepath" "x.lua" "-"];
          };
          language-servers = [
            "lua-language-server"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }

        {
          name = "typescript";
          scope = "source.ts";
          file-types = ["ts" "tsx"];
          roots = ["package.json" "tsconfig.json"];
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "typescript"];
          };
          language-servers = [
            "typescript-language-server"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }

        {
          name = "javascript";
          scope = "source.js";
          file-types = ["js" "jsx"];
          roots = ["package.json"];
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "babel"];
          };
          language-servers = [
            "typescript-language-server"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }

        {
          name = "python";
          scope = "source.python";
          file-types = ["py" "pyi"];
          roots = ["pyproject.toml" "setup.py"];
          auto-format = true;
          formatter = {
            command = "black";
            args = ["-"];
          };
          language-servers = [
            "pylsp"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 4;
            unit = " ";
          };
        }

        {
          name = "nix";
          scope = "source.nix";
          file-types = ["nix"];
          roots = ["flake.nix" "shell.nix" "default.nix"];
          auto-format = true;
          formatter.command = "alejandra";
          language-servers = [
            "nixd"
            "nil"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }

        {
          name = "toml";
          scope = "source.toml";
          file-types = ["toml" "Cargo.lock"];
          auto-format = true;
          formatter = {
            command = "taplo";
            args = ["fmt" "-"];
          };
          language-servers = [
            "taplo"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }

        {
          name = "json";
          scope = "source.json";
          file-types = ["json"];
          auto-format = true;
          formatter = {
            command = "prettier";
            args = ["--parser" "json"];
          };
          language-servers = [
            "vscode-json-language-server"
            "llm-suggest"
            "colors"
            "scls"
          ];
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }

        {
          name = "kdl";
          formatter = {
            command = "kdlfmt";
            args = ["format" "-"];
          };
          auto-format = true;
        }
      ];
    };
  };

  xdg.configFile = {
    "helix/yazi-picker.sh" = {
      source = ../../configs/helix/yazi-picker.sh;
      executable = true;
    };

    # programs.helix owns the generated config.toml. We only attach an
    # onChange hook so running `home-manager switch` reloads open Helix
    # instances without replacing the generated file with an external one.
    "helix/config.toml".onChange = ''
      ${pkill} -u $USER -USR1 hx || true
    '';
  };
}
