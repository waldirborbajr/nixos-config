-- =============================================================================
-- AUTOCOMMANDS (unified version)
-- =============================================================================
-- Autocmds are loaded automatically on the VeryLazy event.
-- Consolidated file: duplicates removed, conflicting rules resolved
-- and some new autocmds added (see the report sent along with the file).

local autocmd = vim.api.nvim_create_autocmd

local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- =============================================================================
-- PERFORMANCE / GENERAL
-- =============================================================================

-- Checks if the file changed outside Neovim (debounced)
local _checktime_timer = nil
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  desc = "Check for external file changes (debounced)",
  callback = function()
    if _checktime_timer then
      _checktime_timer:stop()
      _checktime_timer:close()
      _checktime_timer = nil
    end
    _checktime_timer = vim.defer_fn(function()
      _checktime_timer = nil
      if vim.o.buftype ~= "nofile" then
        vim.cmd("checktime")
      end
    end, 200)
  end,
})

-- Resizes splits proportionally when the terminal window changes
local _resize_timer = nil
autocmd("VimResized", {
  group = augroup("resize_splits"),
  desc = "Rebalance splits on window resize (debounced)",
  callback = function()
    if _resize_timer then
      _resize_timer:stop()
      _resize_timer:close()
      _resize_timer = nil
    end
    local current_tab = vim.fn.tabpagenr()
    _resize_timer = vim.defer_fn(function()
      _resize_timer = nil
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end, 100)
  end,
})

-- [NEW] Disable heavy features in very large files (>1MB)
autocmd("BufReadPre", {
  group = augroup("large_file"),
  desc = "Disable swapfile, spell, folds and treesitter in large files",
  callback = function(event)
    local name = vim.api.nvim_buf_get_name(event.buf)
    local ok, stats = pcall(function()
      return vim.uv.fs_stat(name)
    end)
    if ok and stats and stats.size > 1024 * 1024 then
      vim.b[event.buf].large_file = true
      vim.bo[event.buf].swapfile = false
      vim.opt_local.spell = false
      vim.opt_local.foldmethod = "manual"
      vim.schedule(function()
        pcall(vim.treesitter.stop, event.buf)
      end)
    end
  end,
})

-- =============================================================================
-- BUFFER & CURSOR
-- =============================================================================

-- Restores the last cursor position when reopening a file
-- (merges "last_loc" and "last_location": filetype guard + centers the screen)
autocmd("BufReadPost", {
  group = augroup("last_loc"),
  desc = "Restore last cursor position",
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.cmd, [[normal! g`"zz]])
    end
  end,
})

-- Automatically creates intermediate directories on save, if they don't exist
autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  desc = "Automatically create destination directory on save",
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- =============================================================================
-- UI / EDITING EXPERIENCE
-- =============================================================================

-- Improves visual performance during insert mode (turns off cursorline/relativenumber)
autocmd("InsertEnter", {
  group = augroup("insert_ui_perf"),
  desc = "Simplify UI when entering insert mode",
  callback = function()
    vim.wo.cursorline = false
    vim.wo.relativenumber = false
    vim.wo.number = true
  end,
})

autocmd("InsertLeave", {
  group = augroup("insert_ui_perf"),
  desc = "Restore UI when leaving insert mode",
  callback = function()
    vim.wo.cursorline = true
    vim.wo.relativenumber = true
  end,
})

-- Treats "-" as part of a word in CSS/HTML/JSX etc. (useful for kebab-case classes)
autocmd("FileType", {
  group = augroup("iskeyword_kebab"),
  desc = "Include '-' in iskeyword for kebab-case based files",
  pattern = { "css", "scss", "less", "html", "htmldjango", "blade", "typescriptreact", "javascriptreact" },
  callback = function()
    vim.opt_local.iskeyword:append("-")
  end,
})

-- Highlights yanked text for a short period
autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  desc = "Visually highlight yanked text",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Fixes conceallevel in JSON files (avoids hiding quotes/braces)
autocmd("FileType", {
  group = augroup("json_conceal"),
  desc = "Disable conceal in JSON files",
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- =============================================================================
-- SPECIAL FILETYPES (close, indentation, detection)
-- =============================================================================

-- Closes certain buffer types with "q" and removes them from the buffer list
autocmd("FileType", {
  group = augroup("close_with_q"),
  desc = "Close utility buffers with 'q'",
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- Adjustments for man pages (merges "man_unlisted" + "man_page_indent")
autocmd("FileType", {
  group = augroup("man_settings"),
  desc = "Unlisted man page buffer + narrow indentation",
  pattern = "man",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.bo[event.buf].shiftwidth = 1
    vim.bo[event.buf].tabstop = 1
  end,
})

-- Wrap, linebreak and spellcheck for "prose" files
-- (merges "wrap_spell" x2 + alternative "wrap_spell" + "BetterReadForTextFiles")
autocmd("FileType", {
  group = augroup("wrap_spell"),
  desc = "Enable wrap, linebreak and spell in text/markdown files",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Ensures .md/.mdx are detected as markdown
-- (previous version duplicated wrap/linebreak/nospell, conflicting with "wrap_spell")
autocmd({ "BufNewFile", "BufFilePre", "BufRead" }, {
  group = augroup("markdown_filetype"),
  desc = "Detect .md/.mdx as markdown",
  pattern = { "*.md", "*.mdx" },
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})

-- Fixes syntax highlighting in special buffers
autocmd("FileType", {
  group = augroup("syntax_highlighting_fix"),
  desc = "Fix syntax highlighting in special buffers",
  pattern = { "gitsendemail", "conf", "editorconfig", "qf", "checkhealth", "less" },
  callback = function(event)
    vim.bo[event.buf].syntax = vim.bo[event.buf].filetype
  end,
})

-- keywordprg for Vimscript files (search in :help)
autocmd("FileType", {
  group = augroup("vim_help_lookup"),
  desc = "Use :help as keywordprg in Vim files",
  pattern = "vim",
  command = "setlocal keywordprg=:vert\\ help",
})

-- Uses real tabs (not spaces) for Go and Rust
autocmd("FileType", {
  group = augroup("tab_for_indent"),
  desc = "Use hard tabs in Go and Rust",
  pattern = { "go", "rust" },
  callback = function()
    vim.bo.expandtab = false
  end,
})

-- Sets filetype for .env and .env.*
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("env_filetype"),
  desc = "Set filetype=sh for .env files",
  pattern = { "*.env", ".env.*" },
  callback = function()
    vim.opt_local.filetype = "sh"
  end,
})

-- Sets filetype for *.tomg-config* files
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("toml_filetype"),
  desc = "Set filetype=toml for *.tomg-config*",
  pattern = { "*.tomg-config*" },
  callback = function()
    vim.opt_local.filetype = "toml"
  end,
})

-- Sets filetype for .ejs files
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("ejs_filetype"),
  desc = "Set filetype=embedded_template for .ejs",
  pattern = { "*.ejs", "*.ejs.t" },
  callback = function()
    vim.opt_local.filetype = "embedded_template"
  end,
})

-- Sets filetype for .code-snippets files
autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("code_snippets_filetype"),
  desc = "Set filetype=json for .code-snippets",
  pattern = { "*.code-snippets" },
  callback = function()
    vim.opt_local.filetype = "json"
  end,
})

-- =============================================================================
-- COMMENTS
-- =============================================================================

-- Disables automatic comment continuation on new lines
autocmd({ "FileType", "BufEnter" }, {
  group = augroup("no_auto_comment"),
  desc = "Disable automatic comment continuation",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- =============================================================================
-- TEXT EDITING
-- =============================================================================

-- Removes trailing whitespace at end of lines on save
-- (improvement: ignores filetypes where trailing whitespace is significant,
-- such as markdown, which uses 2 trailing spaces to force a line break)
autocmd("BufWritePre", {
  group = augroup("remove_trailing_whitespace"),
  desc = "Remove trailing whitespace on save (except markdown/diff)",
  callback = function(event)
    local exclude = { "markdown", "diff" }
    if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Automatically fixes with `oxlint --fix` on save, if the project has a config
local function root_has_oxlint(path)
  return vim.fs.find({
    ".oxlintrc.json",
    ".oxlintrc.jsonc",
    "oxlint.config.ts",
  }, {
    upward = true,
    path = path,
    stop = vim.loop.os_homedir(),
  })[1] ~= nil
end

autocmd("BufWritePre", {
  group = augroup("oxlint_fix_on_save"),
  desc = "Run oxlint --fix on save (if configured in the project)",
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.vue", "*.svelte", "*.astro" },
  callback = function(args)
    local path = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf))
    if not root_has_oxlint(path) then
      return
    end

    local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "oxlint" })
    if #clients == 0 then
      return
    end

    clients[1]:request_sync("workspace/executeCommand", {
      command = "oxc.fixAll",
      arguments = {
        {
          uri = vim.uri_from_bufnr(args.buf),
          version = vim.lsp.util.buf_versions[args.buf],
        },
      },
    }, 1000, args.buf)
  end,
})

-- Format on save via efm-langserver (optional, disabled by default)
-- local lsp_fmt_group = augroup("format_on_save")
-- autocmd("BufWritePre", {
--   group = lsp_fmt_group,
--   callback = function()
--     require("mini.trailspace").trim()
--     local efm = vim.lsp.get_clients({ name = "efm" })
--     if vim.tbl_isempty(efm) then
--       return
--     end
--     vim.lsp.buf.format({ name = "efm", async = true })
--   end,
-- })

-- =============================================================================
-- TREE-SITTER
-- =============================================================================

-- Starts Tree-sitter automatically via native API
autocmd("FileType", {
  group = augroup("treesitter_start"),
  desc = "Start Tree-sitter automatically",
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
  end,
})

-- =============================================================================
-- FOLDS & DISPLAY
-- =============================================================================

-- Open all folds automatically (optional, disabled by default)
-- autocmd("BufEnter", {
--   group = augroup("open_folds"),
--   desc = "Open all folds when entering the buffer",
--   command = "silent! normal! zR",
-- })

-- =============================================================================
-- TERMINAL
-- =============================================================================

-- Syncs Neovim's cwd with the terminal process directory
autocmd({ "BufEnter", "TermEnter", "TermLeave" }, {
  group = augroup("terminal_cwd_sync"),
  desc = "Sync cwd with the terminal buffer",
  pattern = "term://*",
  callback = function()
    local cwd = vim.fn.resolve("/proc/" .. vim.b.terminal_job_pid .. "/cwd")
    if vim.fn.isdirectory(cwd) == 1 then
      vim.fn.chdir(cwd)
    end
  end,
})

-- Disables scrolloff inside the terminal for better UX
autocmd("TermEnter", {
  group = augroup("terminal_scrolloff"),
  desc = "Disable scrolloff in the terminal",
  pattern = "term://*",
  callback = function()
    vim.b.saved_scrolloff = vim.o.scrolloff
    vim.o.scrolloff = 0
  end,
})

-- Restores scrolloff when leaving the terminal
autocmd("BufLeave", {
  group = augroup("terminal_scrolloff_restore"),
  desc = "Restore scrolloff on terminal exit",
  pattern = "term://*",
  callback = function()
    if vim.b.saved_scrolloff ~= nil then
      vim.o.scrolloff = vim.b.saved_scrolloff
    end
  end,
})

-- [NEW] Cleaner UI inside the terminal (no numbers/signcolumn)
autocmd("TermOpen", {
  group = augroup("terminal_ui"),
  desc = "Disable number/relativenumber/signcolumn in terminal buffers",
  pattern = "term://*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- =============================================================================
-- USER COMMANDS
-- =============================================================================

-- Add plugins using pack.lua
vim.api.nvim_create_user_command("PackAdd", function(opts)
  vim.pack.add(opts.fargs)
end, {
  nargs = "+",
  desc = "Add plugins (:PackAdd user/repo1 user/repo2)",
})

-- Remove plugins from pack.lua
vim.api.nvim_create_user_command("PackDel", function(opts)
  vim.pack.del(opts.fargs)
end, {
  nargs = "+",
  desc = "Delete plugins (:PackDel plugin1 plugin2)",
})

-- Update all plugins or specific ones
vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if opts.args:match("%S") then
    local plugins = vim.split(opts.args, "%s+", { trimempty = true })
    vim.pack.update(plugins)
  else
    vim.pack.update()
  end
end, {
  nargs = "*",
  desc = "Update all plugins or specific ones (:PackUpdate [plugin1 plugin2])",
})

-- List non-active plugins and optionally delete them
vim.api.nvim_create_user_command("PackCheck", function()
  local non_active = vim
    .iter(vim.pack.get())
    :filter(function(x)
      return not x.active
    end)
    :map(function(x)
      return x.spec.name
    end)
    :totable()

  if #non_active == 0 then
    vim.notify("🆗 No non-active plugins found!", vim.log.levels.INFO)
    return
  end

  vim.print("😴 Non-active plugins :")
  print(" ")
  for _, name in ipairs(non_active) do
    print(name)
  end

  print(" ")

  local choice = vim.fn.confirm(
    "Delete ALL non-active plugins from disk?",
    "&Yes\n&No",
    2 -- default = No
  )

  if choice == 1 then
    vim.pack.del(non_active)
    vim.notify("🗑️  Deleted " .. #non_active .. " non-active plugin(s)", vim.log.levels.INFO)
    print("Non-active plugins deleted!")
    vim.api.nvim_exec_autocmds("User", { pattern = "PackChanged" })
  else
    vim.notify("Cancelled. No plugins were deleted!", vim.log.levels.INFO)
  end
end, { desc = "List non-active plugins and select to delete" })

-- Save macro to file
vim.api.nvim_create_user_command("SaveMacro", function(params)
  local name = params.args
  local dir = vim.fn.expand("~/.config/nvim/macros/")
  local file = dir .. name .. ".macro"
  local content = vim.fn.getreg("q")

  vim.fn.mkdir(dir, "p")
  vim.fn.writefile({ content }, file, "a")
end, { nargs = 1, desc = "Save macro from register q to file" })

-- Load macro from file
vim.api.nvim_create_user_command("LoadMacro", function(params)
  local name = params.args
  local dir = vim.fn.expand("~/.config/nvim/macros/")
  local file = dir .. name .. ".macro"

  local content = vim.fn.readfile(file)
  vim.fn.setreg("q", content)
end, { nargs = 1, desc = "Load macro from file to register q" })

-- Reload configuration
vim.api.nvim_create_user_command("Reload", function()
  vim.cmd(":source $MYVIMRC")
end, { desc = "Reload Neovim configuration" })
