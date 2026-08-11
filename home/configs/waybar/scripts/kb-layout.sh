#!/usr/bin/env bash
# Lê o layout ativo do niri e devolve uma sigla curta pro waybar.
# Usa o índice (current_idx), não o nome completo — assim não depende
# de como o XKB descreve cada layout por extenso.

idx=$(niri msg -j keyboard-layouts | jq -r '.current_idx')

case "$idx" in
    0) echo "US" ;;
    1) echo "INTL" ;;
    *) echo "?$idx" ;;
esac
