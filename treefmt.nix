# ./treefmt.nix
_: {
  # Árvore do projeto — o treefmt sobe até encontrar este arquivo e
  # varre recursivamente TODO o repo a partir daqui, aplicando apenas
  # os formatadores habilitados abaixo (todos restritos a *.nix).
  projectRootFile = "flake.nix";

  programs = {
    # ─── Nix ──────────────────────────────────────────────────────────
    # ⚠️  Escolha UM formatter de Nix. `alejandra` e `nixfmt` são
    # mutuamente exclusivos — habilitar os dois gera conflito.
    alejandra.enable = true;
    # nixfmt.enable = true;  # alternativa oficial (RFC 166) — descomente se migrar

    # Linters Nix (não reformatam, só apontam problemas)
    deadnix.enable = true; # remove `let`/`inherit` não usados
    statix.enable = true; # anti-patterns
  };

  # 🔒 Restringe TUDO a arquivos .nix. Sem isso, os linters acima já se
  # limitam a .nix por padrão, mas o `global.includes` deixa explícito
  # e impede que qualquer formatador futuro (prettier, shfmt, etc.)
  # toque em outros arquivos por engano.
  settings.global.includes = ["*.nix"];

  # Arquivos/paths que o treefmt deve IGNORAR.
  settings.global.excludes = [
    # 🔐 Segredos (nunca tocar)
    "secrets/*"

    # 🔗 Symlinks e artefatos do Nix
    "result"
    "result-*"
    ".direnv"
    ".devenv"

    # 🗂️  Build / cache
    "target/"
    "node_modules/"
    ".cache/"

    # 🖥️  Hardware configs geradas — reformatar faz o próximo
    # `nixos-generate-config` gerar diff enorme. Descomente se quiser
    # ignorar:
    # "hosts/*/hardware-configuration.nix"
  ];
}
