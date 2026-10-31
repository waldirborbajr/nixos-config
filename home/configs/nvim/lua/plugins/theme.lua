-- Tema base16 (Nord) vindo da paleta central do Nix (lua/theme/palette.lua).
-- O plugin aplica o esquema no setup; o LazyVim não precisa de colorscheme.
return {
  {
    "RRethy/base16-nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("base16-colorscheme").setup(require("theme.palette"))
    end,
  },
  -- Evita que o LazyVim troque o tema padrão (tokyonight) depois do nosso.
  -- { "LazyVim/LazyVim", opts = { colorscheme = "base16-colorscheme" } },
}
