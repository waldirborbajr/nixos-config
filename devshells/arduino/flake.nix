{
  description = "Arduino development environment with arduino-cli";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    arduino-nix.url = "github:bouk/arduino-nix";
    arduino-index = {
      url = "github:bouk/arduino-indexes";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    arduino-nix,
    arduino-index,
    ...
  }: let
    overlays = [
      arduino-nix.overlay
      (arduino-nix.mkArduinoPackageOverlay (arduino-index + "/index/package_index.json"))
      (arduino-nix.mkArduinoLibraryOverlay (arduino-index + "/index/library_index.json"))
    ];
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

        arduinoCli = pkgs.wrapArduinoCLI {
          libraries = [];
          packages = let
            inherit (pkgs.arduinoPackages) platforms;
            latestAvr = builtins.head (
              builtins.sort (a: b: a > b) (builtins.attrNames platforms.arduino.avr)
            );
          in [platforms.arduino.avr.${latestAvr}];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            arduinoCli
            avrdude
          ];

          shellHook = ''
            alias arduino='arduino-cli'

            compile-sketch() {
              if [ -z "$1" ]; then
                echo "Uso: compile-sketch <caminho_do_sketch> [FQBN]"
                echo "FQBN padrão: arduino:avr:uno"
                return 1
              fi
              local FQBN="''${2:-arduino:avr:uno}"
              arduino-cli compile --fqbn "$FQBN" "$1"
            }

            upload-sketch() {
              if [ -z "$1" ]; then
                echo "Uso: upload-sketch <caminho_do_sketch> [porta] [FQBN]"
                echo "Porta padrão: detectada automaticamente"
                echo "FQBN padrão: arduino:avr:uno"
                return 1
              fi
              local FQBN="''${3:-arduino:avr:uno}"
              local PORT=""
              if [ -n "$2" ]; then
                PORT="-p $2"
              fi
              arduino-cli upload $PORT --fqbn "$FQBN" "$1"
            }

            list-boards() {
              arduino-cli board list
            }

            install-library() {
              if [ -z "$1" ]; then
                echo "Uso: install-library <nome_da_biblioteca>"
                return 1
              fi
              arduino-cli lib install "$1"
            }

            list-libraries() {
              arduino-cli lib list
            }

            new-sketch() {
              if [ -z "$1" ]; then
                echo "Uso: new-sketch <nome>"
                return 1
              fi
              arduino-cli sketch new "$1"
            }

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "⚡ Arduino Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 arduino-cli: $(arduino-cli version 2>/dev/null | head -n 1)"
            echo "📦 avrdude:     $(avrdude -version 2>&1 | head -n 1)"
            echo ""
            echo "🔧 Comandos disponíveis (atalhos):"
            echo "   • compile-sketch <sketch> [FQBN]     - Compila o sketch"
            echo "   • upload-sketch <sketch> [porta] [FQBN] - Envia para a placa"
            echo "   • list-boards                        - Lista placas conectadas"
            echo "   • install-library <lib>              - Instala biblioteca"
            echo "   • list-libraries                     - Lista bibliotecas instaladas"
            echo "   • new-sketch <nome>                  - Cria um novo sketch"
            echo "   • arduino                            - alias para arduino-cli"
            echo ""
            echo "💡 Exemplos:"
            echo "   compile-sketch ./blink"
            echo "   upload-sketch ./blink /dev/ttyUSB0"
            echo "   install-library 'Servo'"
            echo "   new-sketch meu_projeto"
            echo ""
            echo "📌 FQBN padrão: arduino:avr:uno (Arduino Uno)"
            echo "   Para outras placas, use: arduino-cli board listall"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      }
    );
}
