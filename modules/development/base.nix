{pkgs, ...}:

{
  # Ferramentas comuns a todos os ambientes de desenvolvimento.
  #
  # Regra: ferramentas compartilhadas entre linguagens/devshells ficam aqui.
  # Os módulos de linguagem/serviço devem declarar somente o que é específico
  # daquele ambiente.
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

    # SQLite is shared by several development environments.
    sqlite
    sqlite-analyzer

    # Editor/tooling available to every development environment.
    # Home Manager owns the Helix configuration; this module owns the
    # development-time package availability.
    helix

    # Hardware information useful during development.
    pciutils
  ];
}
