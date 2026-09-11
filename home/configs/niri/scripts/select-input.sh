#!/usr/bin/env bash
# Seleciona o input.kdl do Niri conforme o hostname.
# Chamado no startup do Niri (spawn-sh-at-startup).

set -euo pipefail

DIR="${HOME}/dotfiles/niri/.config/niri"
cd "$DIR"

case "$(hostname)" in
  dell1564)
    target="input-dell.kdl"
    ;;
  mac2011)
    target="input-mac2011.kdl"
    ;;
  macutm|macvmf)
    target="input-mac.kdl"
    ;;
  *)
    # fallback seguro
    target="input-mac.kdl"
    echo "select-input: hostname '$(hostname)' desconhecido, usando $target" >&2
    ;;
esac

if [[ ! -f "$target" ]]; then
  echo "select-input: arquivo $DIR/$target não encontrado" >&2
  exit 1
fi

ln -sfn "$target" input.kdl
echo "select-input: input.kdl -> $target"
