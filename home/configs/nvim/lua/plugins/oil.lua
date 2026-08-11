return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Oil",
    config = function()
      require("oil").setup({
        default_file_explorer = true,

        -- columns = {
        --  "icon",
        --  "size",
        --  "mtime",
        -- },
        columns = {
          "icon",
        },

        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = true,
        cleanup_delay_ms = 2000,

        constrain_cursor = "name",
        watch_for_changes = true,

        keymaps = {
          ["g?"] = { "actions.show_help", mode = "n" },
          ["<CR>"] = "actions.select",
          ["sv"] = { "actions.select", opts = { vertical = true } },
          ["sh"] = { "actions.select", opts = { horizontal = true } },
          ["st"] = { "actions.select", opts = { tab = true } },
          ["-"] = { "actions.parent", mode = "n" },
          ["_"] = { "actions.open_cwd", mode = "n" },
          ["<BS>"] = { "actions.parent", mode = "n" }, -- Backspace para subir
          ["g."] = { "actions.toggle_hidden", mode = "n" },
          ["gs"] = { "actions.change_sort", mode = "n" },
          ["gx"] = "actions.open_external",
          ["q"] = { "actions.close", mode = "n" },
          ["<C-q>"] = { "actions.close", mode = "n" }, -- cerrar también con Ctrl+q
          ["<C-l>"] = "actions.refresh",
        },

        use_default_keymaps = false,

        view_options = {
          show_hidden = true,
          natural_order = true,
          case_insensitive = true,
          sort = {
            { "type", "asc" },
            { "name", "asc" },
          },
          wrap = true,
        },

        float = {
          padding = 2,
          border = "rounded",
        },

        preview_win = {
          update_on_cursor_moved = true,
          preview_method = "fast_scratch",
        },
      })
    end,
  },
}
