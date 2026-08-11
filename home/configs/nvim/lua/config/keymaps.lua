-- =============================================
-- HELPER FUNCTION: DELETE CHAR OR BLANK LINE
-- =============================================
local function delete_char_or_blank_line()
  if vim.fn.col(".") == 1 and vim.fn.getline("."):match("^%s*$") then
    vim.api.nvim_feedkeys('"_dd', "n", false)
    vim.api.nvim_feedkeys("$", "n", false)
  else
    vim.api.nvim_feedkeys('"_x', "n", false)
  end
end

-- =============================================
-- KEYMAP SHORTCUT FUNCTION
-- =============================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- =============================================
-- CLIPBOARD & REGISTER BEHAVIOR
-- =============================================
-- Copy / Paste to system clipboard
map({ "n", "x" }, "<C-y>", '"+y', { desc = "Copy to system clipboard" })
map("n", "<C-p>", '"+p', { desc = "Paste from system clipboard" })

-- Delete / Change without yanking to default register
map({ "n", "x" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })
map({ "n", "x" }, "c", [["_c]], { desc = "Change without yanking" })
map({ "n", "x" }, "C", [["_C]], { desc = "Change line without yanking" })

-- Delete character or blank line without yanking
map({ "n", "x" }, "x", delete_char_or_blank_line, { desc = "Delete char/line without yanking" })
map({ "n", "x" }, "X", delete_char_or_blank_line, { desc = "Delete char/line without yanking" })

-- Visual paste behavior (does not overwrite register)
map("x", "p", [["_dP]], { desc = "Paste over selection without losing register" })
map("x", "P", "p", { desc = "Yank selection then paste" })

-- =============================================
-- MOVEMENT & CURSOR
-- =============================================
-- Better up/down with word wrap
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move up" })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move down" })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move up" })

-- Centered scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Centered search navigation
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Join lines without moving cursor
map("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

-- Move lines with Alt (Normal, Insert, Visual)
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down in insert mode" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up in insert mode" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move selection up" })

-- =============================================
-- VISUAL MODE ENHANCEMENTS
-- =============================================
-- Move selection up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Indentation
map("v", "<", "<gv", { desc = "Unindent and keep selection" })
map("v", ">", ">gv", { desc = "Indent and keep selection" })

-- Sort / Replace selection
map("v", "<C-s>", "<cmd>sort<CR>", { desc = "Sort selection" })
map("v", "<leader>rr", '"hy:%s/<C-r>h//g<Left><Left>', { desc = "Replace selection" })

-- =============================================
-- WINDOW & SPLIT MANAGEMENT
-- =============================================
-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Window resizing
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase width" })

-- Splits with leader
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- =============================================
-- BUFFERS & TABS
-- =============================================
-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to alternate buffer" })
map("n", "<leader>`", "<cmd>e #<CR>", { desc = "Switch to alternate buffer" })

-- Buffer deletion
map("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete buffer" })
map("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete other buffers" })
map("n", "<leader>bD", "<cmd>bd<CR>", { desc = "Delete buffer + window" })

-- Tab navigation
map("n", "<Tab>", "<cmd>bn<CR>", { desc = "Next buffer (tab)" })
map("n", "<S-Tab>", "<cmd>bp<CR>", { desc = "Previous buffer (tab)" })

-- Tab operations
map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current file in new tab" })

-- =============================================
-- MISCELLANEOUS
-- =============================================

-- Escape alternatives
map("i", "<C-c>", "<Esc>", { desc = "Escape alternative in insert mode" })

-- Clear search highlights
map("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlight", silent = true })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Replace word under cursor globally
map(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor globally" }
)

-- Make current file executable
map("n", "<leader>X", "<cmd>!chmod +x %<CR>", { desc = "Make file executable", silent = true })

-- Open parent directory with Oil
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory (Oil)" })

-- Exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Toggle UndoTree (lazy-loaded)
map("n", "<leader>u", function()
  vim.cmd.packadd("nvim.undotree")
  require("undotree").open()
end, { desc = "Toggle UndoTree" })

-- Restart Neovim configuration
map("n", "<leader>re", "<cmd>restart<CR>", { desc = "Restart Neovim config" })

-- Restart LSP
map("n", "<leader>lr", function()
  vim.cmd("lsp restart")
  vim.notify("LSP restarted", vim.log.levels.INFO)
end, { desc = "Restart LSP" })

-- Format current buffer (built-in LSP)
map("n", "<leader>f", vim.lsp.buf.format, { desc = "Format current buffer" })

-- Copy current file path to clipboard
map("n", "<leader>fp", function()
  local filePath = vim.fn.expand("%:~")
  vim.fn.setreg("+", filePath)
  print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

-- Source current file (quick reload)
map("n", "<leader><leader>", function()
  vim.cmd("so")
end, { desc = "Source current file" })
