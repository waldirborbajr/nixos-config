# Backup e restauração da chave age (SOPS)

## Por que isso existe

Cada host (`macutm`, `dell1564`, `mac2011`, `macvmf`) tem uma chave privada
`age` em `~/.config/sops/age/keys.txt`. Essa chave **nunca vai pro git** —
é ela que decifra `hosts/<host>/secrets/<host>.yaml`, onde ficam guardadas
as chaves SSH (`infra`, `github`) e a `ssh_host_ed25519_key`.

Se o disco de um host for formatado sem backup dessa chave, o `.yaml`
continua intacto no git, mas **fica permanentemente impossível de abrir**.
Nesse caso a única saída é gerar tudo novo para aquele host — incluindo
uma nova `id_ed25519_github`, que exige reautorizar a chave pública no
GitHub e em qualquer lugar que confiava na antiga.

Fazer backup da `age` evita isso: ela é um arquivo de uma linha, muito
mais fácil de guardar com segurança do que reconfigurar acessos depois.

## Procedimento de backup

Rodar em **cada host**, sempre que a chave for gerada ou trocada:

```bash
./scripts/backup-age-key.sh
```

O script imprime:
- a chave pública (só pra conferência, pode ser vista por qualquer um)
- o conteúdo completo de `keys.txt` (segredo — é isso que vai pro backup)

**Onde guardar:** um gerenciador de senhas (Bitwarden, 1Password, etc.),
em uma nota segura por host — por exemplo:

| Entrada no gerenciador | Conteúdo |
|---|---|
| `age-key-macutm`      | conteúdo de `keys.txt` da MacBook M2 - UTM |
| `age-key-dell1564`    | conteúdo de `keys.txt` do Dell Inspiron 1456 |
| `age-key-mac2011`     | conteúdo de `keys.txt` do MacBook Pro 2011 |
| `age-key-macvmf`      | conteúdo de `keys.txt` da MacBook M2 - VMware Fusion |

**Nunca:**
- commitar esse conteúdo no git (nem em repo privado)
- colar em chat, issue, ticket ou qualquer lugar que logue texto
- salvar em arquivo `.txt` sem criptografia em outro disco

## Procedimento de restauração (reinstalação de um host)

1. Instalar o NixOS do zero e clonar `nixos-config`.
2. **Antes do primeiro `nixos-rebuild`**, restaurar a chave:
   ```bash
   mkdir -p ~/.config/sops/age
   # colar o conteúdo salvo no gerenciador de senhas em:
   nano ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```
3. Rodar o rebuild normalmente:
   ```bash
   sudo nixos-rebuild switch --flake .#<host>
   ```
   O sops-nix decifra `hosts/<host>/secrets/<host>.yaml` com a chave
   restaurada e recoloca as mesmas chaves SSH de antes.
4. Conferir que a chave pública bate com a de antes:
   ```bash
   age-keygen -y ~/.config/sops/age/keys.txt
   ```
   (deve ser idêntica à que está anotada junto do backup)
5. Confirmar acesso ao GitHub sem precisar reautorizar nada:
   ```bash
   ssh -T git@github.com -i ~/.ssh/id_ed25519_github
   ```

Se por algum motivo o backup não existir (chave perdida de verdade),
seguir o fluxo de "primeira instalação" normal — gerar tudo novo via
`./scripts/manage-ssh-sops.sh <host>` — e depois reautorizar a nova
chave pública no GitHub e em qualquer `authorized_keys` da infra.

## Checklist

- [ ] `age-key-macutm` salva no gerenciador de senhas
- [ ] `age-key-dell1456` salva no gerenciador de senhas
- [ ] `age-key-mac2011` salva no gerenciador de senhas
- [ ] `age-key-macvmf` salva no gerenciador de senhas
- [ ] Testado ao menos um restore (mesmo que num host de teste) para
      validar que o procedimento funciona antes de precisar dele de verdade

## Melhoria futura (opcional): chave admin como recipient extra

Em vez de depender só da chave individual de cada host, o sops-nix
permite múltiplos recipients por arquivo `.yaml`. Adicionando uma chave
"admin" sua (guardada centralizadamente) como recipient extra em todo
`secrets/*.yaml`, você consegue decifrar/recriar o segredo de qualquer
host mesmo sem o backup específico daquele host — reduz a dependência de
manter o checklist acima 100% em dia. Se quiser, dá pra configurar isso
depois como um passo separado.
