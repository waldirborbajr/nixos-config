# Development module refactor

This revision consolidates the tools that previously lived only in
`devshells/*` into `modules/development/*`.

## Layout

- `modules/development/base.nix`: common development/build/debug/database
  utilities shared across environments.
- `go.nix`: Go compiler and Go-specific tooling only.
- `rust.nix`: Rust toolchain and Rust-specific tooling only.
- `python.nix`: Python/uv/Python tooling only.
- `lua.nix`: Lua tooling only.
- `arduino.nix`: Arduino CLI and AVR flashing tool.
- `latex.nix`: LaTeX/Typst and their preview/watch/build tooling.
- database modules: database server/client tools; server services are disabled
  by default.
- `sqlite.nix`: extension point; SQLite binaries are owned by `base.nix`.

## Important ownership changes

The following were removed from `modules/nixos/packages.nix` because they
are development-owned or already have a dedicated Home Manager owner:

- git
- ripgrep
- tree
- helix
- zathura

Host-level duplicate development packages were also removed from the common
Mac and Dell package lists where the development modules now own them.

## Intentional exceptions

A devshell can contain project-specific shell hooks, aliases, environment
variables, uv2nix workspaces, generated virtualenvs, or overlays. Those are
not equivalent to system packages and therefore remain in the devshells.

Arduino's old `arduino-nix` wrapper embedded an AVR core in `arduino-cli`.
The NixOS module exposes the same CLI/AVR flashing tools, while board cores
are installed explicitly with `arduino-cli core install ...`.

The database modules no longer start database daemons automatically merely
because `modules/development/default.nix` is imported. Enable a database
service explicitly on a host when it is actually needed.
