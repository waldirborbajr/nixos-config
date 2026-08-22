# Split de `configuration.nix` — notas do refactor

Split puramente estrutural do `configuration.nix` (516 linhas) em módulos
por tópico. **Nenhuma opção de comportamento foi alterada** — é o mesmo
conteúdo, reorganizado. `imports = [ ... ]` no NixOS faz merge de
atributos exatamente como se tudo estivesse em um arquivo só.

## O que mudou

- `configuration.nix` virou um índice fino: `let` com `username`/`common`
  (mantido, porque `hosts/dell1564/default.nix`, `hosts/mac2011/default.nix`
  e `hosts/common/mac-vm-workstation.nix` fazem `inherit (common) username;`
  e dependem desse `_module.args.common`) + lista de `imports` +
  `system.stateVersion`.
- `flake.nix` **não mudou** — o mecanismo de `common` via `_module.args`
  já existia e continua sendo a forma dos módulos novos pegarem `username`.
- 9 arquivos novos em `modules/nixos/`, cada um mapeando 1:1 pra seções
  que já existiam (marcadas por comentários `# ==== ... ====`) no arquivo
  original:

| Arquivo novo | Seções do `configuration.nix` original |
|---|---|
| `system-base.nix` | Kernel, tmpfiles (ssh dir + regreet), sleep policy, security/session, network, time/locale |
| `fonts.nix` | Fonts |
| `users-and-home.nix` | Shell, users, home-manager wiring, sudo |
| `desktop-niri.nix` | Niri, greetd/regreet, display manager, power-profiles-daemon, dconf, direnv, xdg portal |
| `audio.nix` | Pulseaudio/pipewire/rtkit |
| `hardware-quirks.nix` | nix-ld, bluetooth (comentários de troubleshooting preservados) |
| `packages.nix` | allowUnfree, env vars, aliases, systemPackages, nix.gc/optimise/settings |
| `ssh.nix` | openssh (server) + programs.ssh (client config) |
| `sops.nix` | sops + secrets + serviço de bootstrap da host key |

## Como validar antes de mergear

Sem `nix` disponível no ambiente onde gerei isso, então a validação aqui
foi um diff semântico linha-a-linha (removendo comentários/whitespace)
entre o corpo do `configuration.nix` original e a soma dos 9 arquivos
novos — bateu 100%, só os 3 caminhos relativos citados acima mudaram
(esperado, os arquivos moveram de diretório).

Na sua branch de teste, o jeito definitivo de confirmar "zero mudança de
comportamento" é comparar o store path final, host por host:

```sh
# antes do split (checkout da main)
nix build .#nixosConfigurations.dell.config.system.build.toplevel
readlink result   # anota o /nix/store/xxxx...

# depois do split (sua branch)
nix build .#nixosConfigurations.dell.config.system.build.toplevel
readlink result   # tem que ser o MESMO store path
```

Repita para `m2utm`, `macvmf` e `mac2011`. Se os 4 baterem, é prova
matemática de que o split não mudou nada — não é "parece igual", é
literalmente o mesmo derivation hash.

Bônus: `nix fmt` (treefmt: alejandra + deadnix + statix) já está
configurado no repo — rode antes do build pra garantir que os arquivos
novos passam no lint que você já tinha.
