# features.nix
#
# O painel único: aqui — e só aqui — se liga/desliga instalação de
# pacotes por host, independente do hardware. Cada host em hosts/ faz
# `// (import ../../features.nix).<hostname>` no fim do seu
# configuration.nix, então os nomes de option usados abaixo
# (development.languages.*, containerTools.*) continuam sendo os
# mesmos que modules/dev/*.nix e modules/containers*.nix já esperam —
# nada mudou na implementação, só passou a existir 1 lugar pra ver e
# editar os 4 hosts lado a lado.
#
# Hoje os 4 hosts NixOS nascem com os MESMOS valores (era o que
# configuration.nix fixava, igual pra todos, sem opção de variar por
# host). Ajuste livremente daqui pra frente — ex.: `python.enable = true;`
# só no mac2011, sem tocar em mais nada.
let
  # Baseline de hoje, repetida pros 4 hosts (nenhum comportamento mudou).
  baseline = {
    development.languages = {
      nix.enable = true;
      go.enable = true;
      rust.enable = true;

      python.enable = false;
      lua.enable = false;
      arduino.enable = false;
      latex.enable = false;
      postgresql.enable = false;
      mariadb.enable = false;
      mongodb.enable = false;
      ferretdb.enable = false;
      sqlite.enable = false;
    };

    containerTools = {
      docker.enable = false;
      podman.enable = false;
      kubernetes.enable = false;
    };
  };
in {
  dell1564 = baseline;
  mac2011 = baseline;
  macutm = baseline;
  macvmf = baseline;

  # O macbook (home-manager standalone, sem NixOS) não tem
  # development.languages.*/containerTools.* — essas options vivem em
  # modules/dev/*.nix e modules/containers*.nix, que ele não importa.
  # Os equivalentes dele (editors.emacs/neovim.enable) ficam em
  # home/macbook.nix por enquanto — ver nota no README sobre trazer
  # isso pra cá também numa próxima fase.
}
