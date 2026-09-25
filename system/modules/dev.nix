# system/modules/dev.nix
#
# Toolchains de desenvolvimento, uma por linguagem/serviço, cada uma
# opt-in via development.languages.<nome>.enable. Era uma pasta
# (system/modules/dev/*.nix, um arquivo por linguagem); achatado num
# arquivo só pra bater com a estrutura de referência — o conteúdo de
# cada linguagem é literalmente o mesmo, só perdeu a pasta.
{
  config,
  lib,
  pkgs,
  ...
}: {
  options.development.languages = {
    nix.enable = lib.mkEnableOption "Nix development tooling";
    go.enable = lib.mkEnableOption "Go development tooling";
    python.enable = lib.mkEnableOption "Python development tooling";
    rust.enable = lib.mkEnableOption "Rust development tooling";
    lua.enable = lib.mkEnableOption "Lua development tooling";
    arduino.enable = lib.mkEnableOption "Arduino development tooling";
    latex.enable = lib.mkEnableOption "LaTeX/Typst development tooling";
    postgresql.enable = lib.mkEnableOption "PostgreSQL development tooling";
    mariadb.enable = lib.mkEnableOption "MariaDB development tooling";
    mongodb.enable = lib.mkEnableOption "MongoDB development tooling";
    ferretdb.enable = lib.mkEnableOption "FerretDB development tooling";
    sqlite.enable = lib.mkEnableOption "SQLite development tooling";
  };

  config = lib.mkMerge [
    # ==================== BASE (sempre presente) ====================
    # Ferramentas comuns a todos os ambientes de desenvolvimento.
    #
    # Regra: ferramentas compartilhadas entre linguagens/devshells ficam
    # aqui. Os blocos de linguagem abaixo declaram só o que é específico
    # daquele ambiente.
    {
      environment.systemPackages = with pkgs; [
        # C/C++ / build foundation
        gcc
        glibc
        clang
        cmake
        libtool
        gnumake
        sdbus-cpp

        # Build/development helpers
        pkg-config
        openssl
        zlib
        jq

        # Source/code navigation
        git
        ripgrep
        fd
        tree

        # Debugging / tracing
        gdb
        lldb
        valgrind
        strace
        ltrace
        graphviz

        # File watching / automation
        watchexec

        # Hardware information useful during development.
        pciutils
      ];
    }

    (lib.mkIf config.development.languages.nix.enable {
      # Nix language tooling: language servers and formatter.
      # These are intentionally kept out of the global NixOS package set.
      environment.systemPackages = with pkgs; [
        nixd
        nil
        alejandra
      ];
    })

    (lib.mkIf config.development.languages.go.enable {
      # Somente ferramentas específicas do ecossistema Go.
      environment.systemPackages = with pkgs; [
        go_1_25
        gopls
        gotools
        gomodifytags
        gotests
        gore
        gofumpt
        golangci-lint
        golangci-lint-langserver
        go-task
        air
        goreleaser
        impl
        delve
      ];
    })

    (lib.mkIf config.development.languages.python.enable {
      # Somente Python e ferramentas específicas do ecossistema Python.
      # uv2nix/pyproject-nix continua sendo responsabilidade dos devshells
      # por projeto; aqui instalamos as ferramentas que precisam estar
      # disponíveis no ambiente de desenvolvimento geral.
      environment.systemPackages = with pkgs; [
        python313
        uv
        python313Packages.python-lsp-server
        black
        ruff
      ];
    })

    (lib.mkIf config.development.languages.rust.enable {
      # ════════════════════════════════════════════════════════════════
      #  Rust Toolchain — Sincronizado via rust-bin (rust-overlay)
      #
      #  IMPORTANTE: NÃO use `rustc`, `cargo`, `rust-analyzer`, `rustfmt`,
      #  `clippy` individualmente do nixpkgs! Use APENAS o `rust-bin`
      #  abaixo. Caso contrário, o `rust-analyzer` do nixpkgs (antigo)
      #  sobrescreve o do rust-overlay, causando o bug "cannot index
      #  into &[i32]".
      # ════════════════════════════════════════════════════════════════
      environment.systemPackages = with pkgs; [
        # ── Toolchain unificado (ÚNICA fonte de rustc/cargo/rust-analyzer) ──
        (rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src" # Código-fonte da std
            "rust-analyzer" # LSP (VERSÃO SINCRONIZADA!)
            "rustfmt" # Formatador
            "clippy" # Linter
          ];
        })

        # ── Ferramentas do ecossistema Rust (NÃO são parte do toolchain) ──
        cargo-edit
        cargo-watch
        cargo-make
        cargo-nextest
        cargo-tarpaulin
        cargo-audit
        cargo-outdated
        bacon

        # ── Aceleração de build / link ────────────────────────────────
        mold
        sccache
        llvmPackages.bintools
      ];

      # ── Variáveis de ambiente ──────────────────────────────────────
      environment.variables = {
        RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
        RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
        CARGO_TERM_COLOR = "always";
        # O cargo emite hyperlinks OSC 8 (ex: no link do `dev profile` do
        # `cargo run`) quando acha que o terminal suporta. `ansi-color.el`
        # do Emacs só entende/remove escapes SGR (cor) — OSC 8 é outro
        # tipo de sequência e fica cru em qualquer buffer (compile, shell,
        # eat sem term real). Mais simples desligar na fonte do que
        # tentar filtrar isso no Emacs.
        CARGO_TERM_HYPERLINKS = "false";
      };
    })

    (lib.mkIf config.development.languages.lua.enable {
      environment.systemPackages = with pkgs; [
        lua5_4
        luajit
        luarocks
        lua-language-server
        stylua
        selene
      ];
    })

    (lib.mkIf config.development.languages.arduino.enable {
      # Ferramentas Arduino do devshell. O devshell original usava
      # arduino-nix para empacotar o core AVR dentro do arduino-cli. No
      # módulo NixOS mantemos os binários disponíveis; cores/boards podem
      # ser instalados com `arduino-cli core install arduino:avr`
      # conforme o hardware/projeto.
      environment.systemPackages = with pkgs; [
        arduino-cli
        avrdude
      ];
    })

    (lib.mkIf config.development.languages.latex.enable {
      # Toolchain LaTeX/Typst e utilitários específicos desse fluxo.
      environment.systemPackages = with pkgs; [
        texlive.combined.scheme-full
        tex-fmt
        typst
        tinymist
        zathura
        sioyek
        entr
        just
      ];
    })

    (lib.mkIf config.development.languages.postgresql.enable {
      # Ferramentas PostgreSQL. O serviço permanece desativado por
      # padrão: o módulo pode ser habilitado explicitamente quando um
      # host realmente precisar do servidor.
      services.postgresql = {
        enable = lib.mkDefault false;
        package = pkgs.postgresql_16;
        ensureDatabases = ["dev"];
        authentication = ''
          local all all trust
          host all all 127.0.0.1/32 trust
        '';
        settings = {
          log_statement = "all";
          fsync = false;
          synchronous_commit = false;
        };
        extensions = ps:
          with ps; [
            pgvector
            pg_uuidv7
          ];
      };

      environment.systemPackages = with pkgs; [
        postgresql
        pgcli
      ];
    })

    (lib.mkIf config.development.languages.mariadb.enable {
      # Ferramentas MariaDB. O serviço fica desativado por padrão para
      # não transformar o módulo de desenvolvimento em um daemon de
      # sistema.
      services.mysql = {
        enable = lib.mkDefault false;
        package = pkgs.mariadb;
        ensureDatabases = ["dev"];
        ensureUsers = [
          {
            name = "root";
            ensurePermissions = {
              "*.*" = "ALL PRIVILEGES";
            };
          }
        ];
        settings = {
          mysqld = {
            skip-networking = false;
            bind-address = "127.0.0.1";
            port = 3306;
          };
        };
      };

      environment.systemPackages = with pkgs; [
        mariadb
        mycli
      ];
    })

    (lib.mkIf config.development.languages.mongodb.enable {
      services.mongodb = {
        enable = lib.mkDefault false;
        package = pkgs.mongodb;
        bind_ip = "127.0.0.1";
        dbpath = "/var/lib/mongodb";
      };

      environment.systemPackages = with pkgs; [
        mongosh
        mongodb
      ];
    })

    (lib.mkIf config.development.languages.ferretdb.enable {
      # FerretDB não possui um serviço NixOS nativo aqui. Mantemos os
      # binários disponíveis, enquanto o start/stop pode continuar sendo
      # feito pelo devshell ou manualmente.
      environment.systemPackages = with pkgs; [
        ferretdb
        mongosh
      ];
    })

    (lib.mkIf config.development.languages.sqlite.enable {
      # SQLite é tratado como um ambiente de desenvolvimento
      # independente, assim como Rust, Go, Nix etc. Nada de SQLite fica
      # no bloco base acima.
      environment.systemPackages = with pkgs; [
        sqlite
        sqlite-analyzer
      ];
    })
  ];
}
