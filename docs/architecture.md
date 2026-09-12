# Arquitetura do nixos-config

## Princípio geral

A configuração é dividida por responsabilidade: o sistema global fornece
somente recursos necessários ao funcionamento do host; ferramentas de
desenvolvimento ficam em `modules/development`; preferências e dotfiles ficam
no Home Manager.

```text
flake.nix
├── nixosConfigurations
│   └── hosts/<host>/
├── modules/nixos/             # sistema e infraestrutura
├── modules/development/       # ferramentas e ambientes de desenvolvimento
├── devshells/                 # shells de projeto especializados
└── home/                      # usuário e dotfiles
```

## Development

`modules/development/base.nix` é a fonte de verdade para ferramentas comuns
ao desenvolvimento. Ferramentas específicas de linguagem pertencem ao módulo
da respectiva linguagem.

As linguagens são habilitadas explicitamente:

```nix
development.languages = {
  nix.enable = true;
  go.enable = true;
  python.enable = true;
  rust.enable = true;
  lua.enable = true;
};
```

Isso permite reduzir o conjunto por host sem alterar o `base.nix`.

## DevShells

Os `devshells/` continuam sendo ambientes completos e reproduzíveis para
projetos específicos. Ferramentas auxiliares comuns que existiam nos shells
foram refletidas em `modules/development/base.nix`, evitando que a migração
para o módulo de desenvolvimento perca funcionalidades.

## Sistema global

Ferramentas de desenvolvimento não devem ser colocadas em
`modules/nixos/packages.nix`. O pacote global deve ser reservado para
funcionalidade necessária ao sistema, desktop, infraestrutura e ferramentas
que não são específicas de desenvolvimento.

## Validação

```bash
nix fmt
nix flake check
```

O CI também executa a validação do flake e da formatação.
