# home/modules/helix/theme.nix
#
# Tema "onenord" para o Helix, com a mesma estrutura de mapeamento de
# https://github.com/Misterio77/Foundry/blob/main/home/gabriel/features/helix/theme.nix
# mas usando a paleta OneNord (Nord + Atom One Dark) fixa, já que este repo
# não tem o Material You color engine do Foundry.
#
# Paleta: https://github.com/NvChad/base46/blob/v2.5/lua/base46/themes/onenord.lua
let
  c = {
    bg = "#2a303c";
    bg_alt = "#3B4252"; # base01 — containers / linha selecionada
    bg_alt2 = "#434C5E"; # base02 — seleção / popup
    bg_alt3 = "#4C566A"; # base03 — guides / linhas sutis
    muted = "#566074"; # base04 — comentários, texto apagado
    fg = "#bfc5d0"; # base05
    fg_alt = "#c7cdd8"; # base06
    fg_bright = "#ced4df"; # base07
    red = "#d57780"; # base08
    orange = "#e39a83"; # base09
    yellow = "#EBCB8B"; # base0A
    green = "#A3BE8C"; # base0B
    cyan = "#97b7d7"; # base0C
    blue = "#81A1C1"; # base0D
    magenta = "#B48EAD"; # base0E
    brown = "#d57780"; # base0F
  };
in {
  "attributes" = c.orange;
  "comment" = {
    fg = c.muted;
    modifiers = ["italic"];
  };
  "constant" = c.orange;
  "constant.character.escape" = c.cyan;
  "constant.numeric" = c.orange;
  "constructor" = c.blue;
  "debug" = c.muted;
  "diagnostic" = {
    modifiers = ["underlined"];
  };
  "diagnostic.error" = {
    underline = {
      style = "curl";
    };
  };
  "diagnostic.hint" = {
    underline = {
      style = "curl";
    };
  };
  "diagnostic.info" = {
    underline = {
      style = "curl";
    };
  };
  "diagnostic.warning" = {
    underline = {
      style = "curl";
    };
  };
  "diff.delta" = c.orange;
  "diff.minus" = c.red;
  "diff.plus" = c.green;
  "error" = c.red;
  "function" = c.blue;
  "hint" = c.muted;
  "info" = c.blue;
  "keyword" = c.magenta;
  "label" = c.magenta;
  "markup.bold" = {
    fg = c.yellow;
    modifiers = ["bold"];
  };
  "markup.heading" = c.blue;
  "markup.italic" = {
    fg = c.magenta;
    modifiers = ["italic"];
  };
  "markup.link.text" = c.red;
  "markup.link.url" = {
    fg = c.orange;
    modifiers = ["underlined"];
  };
  "markup.list" = c.red;
  "markup.quote" = c.cyan;
  "markup.raw" = c.green;
  "markup.strikethrough" = {
    modifiers = ["crossed_out"];
  };
  "namespace" = c.magenta;
  "operator" = c.fg;
  "special" = c.blue;
  "string" = c.green;
  "type" = c.yellow;
  "ui.background" = {
    bg = c.bg;
  };
  "ui.bufferline" = {
    fg = c.fg;
    bg = c.bg_alt;
  };
  "ui.bufferline.active" = {
    fg = c.bg;
    bg = c.muted;
    modifiers = ["bold"];
  };
  "ui.cursor" = {
    fg = c.fg;
    modifiers = ["reversed"];
  };
  "ui.cursor.insert" = {
    fg = c.yellow;
    modifiers = ["underlined"];
  };
  "ui.cursor.match" = {
    fg = c.yellow;
    modifiers = ["underlined"];
  };
  "ui.cursor.select" = {
    fg = c.yellow;
    modifiers = ["underlined"];
  };
  "ui.cursorline.primary" = {
    fg = c.fg;
    bg = c.bg_alt2;
  };
  "ui.gutter" = {
    bg = c.bg;
  };
  "ui.help" = {
    fg = c.fg;
    bg = c.bg_alt2;
  };
  "ui.linenr" = {
    fg = c.muted;
    bg = c.bg;
  };
  "ui.linenr.selected" = {
    fg = c.fg;
    bg = c.bg_alt2;
    modifiers = ["bold"];
  };
  "ui.menu" = {
    fg = c.fg;
    bg = c.bg_alt2;
  };
  "ui.menu.scroll" = {
    fg = c.muted;
    bg = c.bg_alt2;
  };
  "ui.menu.selected" = {
    fg = c.bg_alt2;
    bg = c.fg;
  };
  "ui.popup" = {
    bg = c.bg_alt2;
  };
  "ui.selection" = {
    bg = c.bg_alt;
    fg = c.fg;
  };
  "ui.selection.primary" = {
    bg = c.bg_alt;
    fg = c.fg;
  };
  "ui.statusline" = {
    fg = c.fg;
    bg = c.bg_alt;
  };
  "ui.statusline.inactive" = {
    bg = c.bg_alt2;
    fg = c.muted;
  };
  "ui.statusline.insert" = {
    fg = c.bg;
    bg = c.green;
  };
  "ui.statusline.normal" = {
    fg = c.bg;
    bg = c.blue;
  };
  "ui.statusline.select" = {
    fg = c.bg;
    bg = c.magenta;
  };
  "ui.text" = c.fg;
  "ui.text.focus" = c.fg;
  "ui.virtual.indent-guide" = {
    fg = c.bg_alt3;
  };
  "ui.virtual.ruler" = {
    bg = c.bg_alt2;
  };
  "ui.virtual.whitespace" = {
    fg = c.bg_alt2;
  };
  "ui.window" = {
    bg = c.bg_alt2;
  };
  "variable" = c.red;
  "variable.other.member" = c.red;
  "warning" = c.orange;
}
