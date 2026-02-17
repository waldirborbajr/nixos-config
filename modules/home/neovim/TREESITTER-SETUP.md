# Tree-sitter Setup for NixOS

## Problem
NixOS cannot run dynamically linked executables, so nvim-treesitter's auto-install feature doesn't work.

## Solution
Tree-sitter grammars are now installed via Nix and symlinked to `~/.local/share/nvim/nix-treesitter/`.

## Required Neovim Configuration

Add this to your nvim-treesitter configuration in your dotfiles:

### Lua Configuration

```lua
require('nvim-treesitter.configs').setup {
  -- IMPORTANT: Disable auto_install on NixOS
  auto_install = false,
  
  -- Add the Nix-provided parser directory
  parser_install_dir = vim.fn.stdpath('data') .. '/nix-treesitter',
  
  -- Your other treesitter settings...
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  -- etc...
}

-- Prepend the Nix parsers to the runtime path
vim.opt.runtimepath:prepend(vim.fn.stdpath('data') .. '/nix-treesitter')
```

## After Setup

1. Rebuild your NixOS/home-manager configuration
2. Update your neovim configuration with the above settings
3. Restart neovim

## Alternative: Install Specific Grammars

If you don't want all grammars, you can specify only the ones you need in `default.nix`:

```nix
home.file.".local/share/nvim/nix-treesitter".source =
  let
    treesitterWithGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
      p.tree-sitter-nix
      p.tree-sitter-lua
      p.tree-sitter-python
      p.tree-sitter-rust
      p.tree-sitter-go
      # Add more as needed
    ]);
  in
  "${treesitterWithGrammars}/parser";
```
