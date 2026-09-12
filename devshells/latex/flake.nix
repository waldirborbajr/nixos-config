{
  description = "LaTeX and Typst development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # LaTeX toolchain
            texlive.combined.scheme-full
            tex-fmt
            # latexindent já vem embutido no texlive.combined.scheme-full,
            # não existe um atributo `pkgs.latexindent` separado no nixpkgs.

            # Typst toolchain
            typst
            tinymist # Language server for Typst

            # Editors
            helix

            # Preview tools
            zathura # PDF viewer with auto-reload
            sioyek # Alternative PDF viewer with synctex support

            # Utilities
            watchexec # For auto-compilation
            entr # Alternative for file watching

            # Build tools
            just # Command runner
          ];

          shellHook = ''
            # Colorful prompt
            echo -e "\033[1;34m╔══════════════════════════════════════════════╗\033[0m"
            echo -e "\033[1;34m║  LaTeX & Typst Development Environment        ║\033[0m"
            echo -e "\033[1;34m╚══════════════════════════════════════════════╝\033[0m"

            # Helpful aliases
            alias latex-build='latexmk -pdf -pvc -view=none'
            alias typst-build='typst compile --watch'
            alias typst-preview='typst watch main.typ --open'

            # Create a justfile if it doesn't exist
            if [ ! -f "justfile" ]; then
              cat > justfile << 'EOF'
            # LaTeX build with live preview
            latex-preview *args:
              latexmk -pdf -pvc -view=none {{args}}

            # LaTeX clean
            latex-clean:
              latexmk -C

            # Typst build
            typst-build file:
              typst compile --watch {{file}}

            # Typst preview
            typst-preview file:
              typst watch {{file}} --open

            # Open PDF with auto-reload
            preview-pdf file:
              zathura {{file}} &
            EOF
              echo "📄 Created justfile with helpful commands"
            fi

            # Show available commands
            echo ""
            echo "📚 Available commands:"
            echo "  • just latex-preview [file]  - Compile LaTeX with auto-reload"
            echo "  • just latex-clean           - Clean LaTeX auxiliary files"
            echo "  • just typst-build [file]    - Watch and compile Typst"
            echo "  • just typst-preview [file]  - Watch, compile and preview Typst"
            echo "  • just preview-pdf [file]    - Open PDF with auto-reload"
            echo "  • helix                      - Open Helix editor"
            echo ""

            # Create basic examples
            if [ ! -f "main.tex" ] && [ ! -f "main.typ" ]; then
              echo "💡 Creating example files..."

              # LaTeX example
              cat > main.tex << 'EOF'
            \documentclass{article}
            \usepackage{amsmath}
            \usepackage{graphicx}
            \usepackage{hyperref}

            \title{Example Document}
            \author{Your Name}
            \date{\today}

            \begin{document}
            \maketitle

            \section{Introduction}
            This is an example LaTeX document.

            \section{Math}
            \begin{equation}
              E = mc^2
            \end{equation}

            \end{document}
            EOF

              # Typst example
              cat > main.typ << 'EOF'
            #set page(width: 8.5in, height: 11in, margin: 1in)
            #set text(font: "Linux Libertine", size: 11pt)

            #set heading(numbering: "1.")

            = Introduction

            This is an example #text(style: "italic")[Typst] document.

            = Math

            $ E = m c^2 $
            EOF

              echo "  ✓ Created main.tex (LaTeX example)"
              echo "  ✓ Created main.typ (Typst example)"
            fi

            # Start Helix with a helpful message
            echo "🎯 To start editing, run: helix main.tex or helix main.typ"
            echo ""
          '';

          # Helix configuration
          HELIX_RUNTIME = "${pkgs.helix}/lib/helix/runtime";
        };

        # Add a package for the flake
        packages.default = pkgs.writeShellScriptBin "dev-env" ''
          echo "Entering LaTeX/Typst development environment..."
          exec ${pkgs.helix}/bin/helix
        '';
      }
    );
}
