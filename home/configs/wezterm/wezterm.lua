-- ══════════════════════════════════════════════════════════════════════
--  WezTerm Configuration
--  Nord theme — Linux x86_64 + macOS Apple Silicon (M2)
-- ══════════════════════════════════════════════════════════════════════
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder and wezterm.config_builder() or {}
local IS_MACOS = wezterm.target_triple:find("apple") ~= nil

-- ── APPEARANCE ────────────────────────────────────────────────────────

config.color_scheme = "nord"
config.default_cursor_style = "SteadyBar"
config.force_reverse_video_cursor = true

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = IS_MACOS and 13.5 or 11.5
config.line_height = 1.2

config.window_decorations = IS_MACOS and "RESIZE" or "NONE"
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }

-- Dim inactive panes
config.inactive_pane_hsb = { saturation = 0.7, brightness = 0.65 }

config.background = {
	{
		source = { Color = "#2e3440" },
		width = "100%",
		height = "100%",
		opacity = 1.0,
	},
}

-- ── BEHAVIOR ──────────────────────────────────────────────────────────

config.initial_cols = 120
config.initial_rows = 40
config.automatically_reload_config = true
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.check_for_updates = false
config.scrollback_lines = 12000
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Faster key repeat (useful in nvim/helix)
config.key_map_preference = "Mapped"

-- ── GRAPHICS BACKEND ─────────────────────────────────────────────────

if IS_MACOS then
	config.max_fps = 30 -- economiza bateria/GPU no M2; sobe pra 60 se quiser mais suavidade
else
	config.prefer_egl = true -- EGL costuma ser mais estável/rápido no Linux (X11/Wayland)
end

-- ── TAB TITLE (dinâmico: mostra o processo em foreground) ──────────────

wezterm.on("format-tab-title", function(tab)
	local pane = tab.active_pane
	local proc = pane.foreground_process_name

	-- extrai só o nome do binário (sem path completo)
	local name = proc and proc:match("([^/\\]+)$") or nil

	-- alguns processos vêm com sufixo estranho (ex: "-zsh"); limpa o "-" inicial
	if name then
		name = name:gsub("^%-", "")
	end

	-- fallback pro nome do shell se não identificar nada
	local title = name or pane.title or "shell"

	return {
		{ Text = " " .. title .. " " },
	}
end)

-- ── STATUS BAR (leader indicator + git branch + workspace + hora) ────
-- Cache for git branch (avoids spawning git on every status update)
local _git_cache = { path = nil, branch = nil, ts = 0 }
local GIT_CACHE_TTL = 3  -- seconds

local function get_git_branch(path)
  local now = os.time()
  if _git_cache.path == path and (now - _git_cache.ts) < GIT_CACHE_TTL then
    return _git_cache.branch
  end
  local ok, stdout = wezterm.run_child_process({
    "git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD",
  })
  local branch = nil
  if ok and stdout then
    branch = stdout:gsub("%s+$", "")
    if branch == "" then
      branch = nil
    end
  end
  _git_cache = { path = path, branch = branch, ts = now }
  return branch
end

wezterm.on("update-status", function(window, pane)
  local cells = {}

  -- indicador visual quando o leader (Ctrl+A) está ativo
  if window:leader_is_active() then
    table.insert(cells, { Foreground = { Color = "#2e3440" } })
    table.insert(cells, { Background = { Color = "#88c0d0" } })
    table.insert(cells, { Text = " LEADER " })
    table.insert(cells, "ResetAttributes")
  end

  -- nome do workspace atual
  table.insert(cells, { Text = " " .. window:active_workspace() .. " " })

  -- se estiver numa sessão remota (SSH), mostra o domínio
  local domain = pane:get_domain_name()
  if domain and domain ~= "local" then
    table.insert(cells, { Text = " 🌐 " .. domain .. " " })
  end

  -- branch git do diretório atual do painel (com cache de 3s)
  local cwd = pane:get_current_working_dir()
  if cwd then
    local path = cwd.file_path or tostring(cwd)
    local branch = get_git_branch(path)
    if branch then
      table.insert(cells, { Text = " 🌿 " .. branch .. " " })
    end
  end

  -- hora
  table.insert(cells, { Text = " " .. wezterm.strftime("%H:%M") .. " " })

  window:set_right_status(wezterm.format(cells))
end)

-- ── STATUS BAR (leader indicator + git branch + workspace + hora) ────
-- wezterm.on("update-status", function(window, pane)
-- 	local cells = {}

-- 	-- indicador visual quando o leader (Ctrl+A) está ativo, esperando o próximo comando
-- 	if window:leader_is_active() then
-- 		table.insert(cells, { Foreground = { Color = "#2e3440" } })
-- 		table.insert(cells, { Background = { Color = "#88c0d0" } })
-- 		table.insert(cells, { Text = " LEADER " })
-- 		table.insert(cells, "ResetAttributes")
-- 	end

-- 	-- nome do workspace atual
-- 	table.insert(cells, { Text = " " .. window:active_workspace() .. " " })

-- 	-- se estiver numa sessão remota (SSH), mostra o domínio
-- 	local domain = pane:get_domain_name()
-- 	if domain and domain ~= "local" then
-- 		table.insert(cells, { Text = " 🌐 " .. domain .. " " })
-- 	end

-- 	-- branch git do diretório atual do painel
-- 	local cwd = pane:get_current_working_dir()
-- 	if cwd then
-- 		local path = cwd.file_path or tostring(cwd)
-- 		local ok, stdout = wezterm.run_child_process({ "git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD" })
-- 		if ok and stdout then
-- 			local branch = stdout:gsub("%s+$", "")
-- 			if branch ~= "" then
-- 				table.insert(cells, { Text = " 🌿 " .. branch .. " " })
-- 			end
-- 		end
-- 	end

-- 	-- hora
-- 	table.insert(cells, { Text = " " .. wezterm.strftime("%H:%M") .. " " })

-- 	window:set_right_status(wezterm.format(cells))
-- end)

-- ── TAB BAR ───────────────────────────────────────────────────────────

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false -- agora em cima
config.enable_tab_bar = true -- habilitado: útil com múltiplas abas/workspaces
config.hide_tab_bar_if_only_one_tab = true -- some quando só tem 1 aba

config.colors = {
	tab_bar = {
		background = "#2e3440",
		active_tab = { bg_color = "#4c566a", fg_color = "#eceff4", intensity = "Bold" },
		inactive_tab = { bg_color = "#2e3440", fg_color = "#7b8394" },
		inactive_tab_hover = { bg_color = "#3b4252", fg_color = "#d8dee9" },
		new_tab = { bg_color = "#2e3440", fg_color = "#4c566a" },
		new_tab_hover = { bg_color = "#3b4252", fg_color = "#88c0d0" },
	},
}

-- ── Quick Select patterns ────────────────────────────────────────────
config.quick_select_patterns = {
  -- Go: path com .go (relativo ou absoluto)
  [[(?:[./\w-]+/)?[\w-]+\.go(?::\d+)?]],

  -- Go: package path estilo module (github.com/foo/bar/...)
  [[(?:[a-z0-9.-]+\.)+[a-z0-9-]+(?:/[\w.-]+)+]],

  -- Git: hash curto/longo (já existe no default, mas reforça)
  [[\b[0-9a-f]{7,40}\b]],

  -- Git: branch comum (feature/..., fix/..., main, master, develop)
  [[\b(?:main|master|develop|dev|staging|prod|feature|fix|hotfix|release)/[\w./-]+\b]],
  [[\b(?:feature|fix|hotfix|release)/[\w./-]+\b]],

  -- Git: ref estilo origin/main
  [[\b[\w.-]+/[\w./-]+\b]],

  -- Docker image:tag
  [[\b[\w./-]+:[\w.-]+\b]],

  -- UUID
  [[\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b]],

  -- Jira / ticket (PROJ-123)
  [[\b[A-Z]{2,10}-\d+\b]],

  -- Hex color
  [[#[0-9a-fA-F]{3,8}\b]],
}

-- ── SSH ───────────────────────────────────────────────────────────────

local ssh_hosts = {
	raspi = {
		label = "🍓 Raspberry Pi",
		user = "borba",
		addr = "192.168.1.101",
	},
}

config.ssh_domains = {}
for id, host in pairs(ssh_hosts) do
	table.insert(config.ssh_domains, {
		name = id,
		remote_address = host.addr,
		username = host.user,
		multiplexing = "None",
	})
end

local function ssh_connect_action()
	local choices = {}
	for id, host in pairs(ssh_hosts) do
		table.insert(choices, {
			id = id,
			label = host.label .. "  " .. host.user .. "@" .. host.addr,
		})
	end
	return act.InputSelector({
		title = "SSH Connect",
		choices = choices,
		action = wezterm.action_callback(function(window, pane, id)
			if not id then
				return
			end
			window:perform_action(
				act.SpawnCommandInNewTab({
					args = { "ssh", ssh_hosts[id].user .. "@" .. ssh_hosts[id].addr },
				}),
				pane
			)
		end),
	})
end

-- ── PROJECTS ──────────────────────────────────────────────────────────
-- Scans $HOME/prj for top-level directories.
-- Results cached per config load — scan_projects() called once at startup,
-- not on every keypress.

local _projects_cache = nil

local function scan_projects()
	if _projects_cache then
		return _projects_cache
	end
	local home = os.getenv("HOME")
	local base = home .. "/prj"
	local _, stdout = wezterm.run_child_process({
		"find",
		base,
		"-mindepth",
		"1",
		"-maxdepth",
		"1",
		"-type",
		"d",
	})
	local projects = {}
	if stdout then
		for line in stdout:gmatch("[^\r\n]+") do
			local name = line:match(".*/(.+)$")
			if name then
				table.insert(projects, { id = name, label = "📁 " .. name, path = line })
			end
		end
		table.sort(projects, function(a, b)
			return a.id < b.id
		end)
	end
	_projects_cache = projects
	return projects
end

local function project_launcher()
	local projects = scan_projects()
	local choices = {}
	for _, p in ipairs(projects) do
		table.insert(choices, { id = p.id, label = p.label })
	end
	return act.InputSelector({
		title = "🚀 Open Project",
		choices = choices,
		action = wezterm.action_callback(function(window, pane, id)
			if not id then
				return
			end
			for _, p in ipairs(projects) do -- projects already in scope — no second scan
				if p.id == id then
					window:perform_action(act.SwitchToWorkspace({ name = p.id, spawn = { cwd = p.path } }), pane)
					return
				end
			end
		end),
	})
end

-- ── KEYBINDINGS ───────────────────────────────────────────────────────
-- Convention:
--   LEADER+hjkl         → navigate panes
--   LEADER+SHIFT+hjkl   → resize panes
--   LEADER+\            → split vertical (new pane to the right)
--   LEADER+-            → split horizontal (new pane below)
--   LEADER+n            → new/switch workspace by name
--   LEADER+t            → new tab
--   LEADER+1..9         → jump to tab by number
--   LEADER+a            → removed (was Ctrl+A passthrough; tmux uses Ctrl+B)

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 800 }

config.keys = {

	-- ── Global (no leader) ──────────────────────────────────────────
	{ key = "F11", mods = "NONE", action = act.ToggleFullScreen },
	{
		key = "l",
		mods = "ALT",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|TABS|DOMAINS|LAUNCH_MENU_ITEMS|WORKSPACES|COMMANDS",
		}),
	},

	-- ── Splits ──────────────────────────────────────────────────────
	-- \ = vertical split (new pane to the right)
	{ key = "\\", mods = "LEADER", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
	-- -  = horizontal split (new pane below)
	{ key = "-", mods = "LEADER", action = act.SplitPane({ direction = "Down", size = { Percent = 40 } }) },

	-- ── Pane navigation (LEADER+hjkl) ───────────────────────────────
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- ── Pane resize (LEADER+SHIFT+hjkl) ─────────────────────────────
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 6 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 6 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 6 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 6 }) },

	-- ── Pane misc ───────────────────────────────────────────────────
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{
		key = "o",
		mods = "LEADER",
		action = wezterm.action_callback(function(_, pane)
			pane:move_to_new_window()
		end),
	},
	
	-- ── Tabs (LEADER+t / LEADER+x / LEADER+X / LEADER+[ / LEADER+]) ──
	{ key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) }, -- fecha só o painel
	{ key = "X", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = false }) }, -- fecha a aba inteira
	{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },

	-- ── Workspaces ──────────────────────────────────────────────────
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{
		key = "n",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "New/switch workspace:",
			action = wezterm.action_callback(function(window, pane, line)
				if line and #line > 0 then
					window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},
	{ key = "p", mods = "LEADER", action = project_launcher() },

	-- ── SSH ─────────────────────────────────────────────────────────
	{ key = "e", mods = "LEADER", action = ssh_connect_action() },

	-- ── Misc ────────────────────────────────────────────────────────
	{ key = "m", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
	{ key = "/", mods = "LEADER", action = act.Search({ CaseInSensitiveString = "" }) },
	{ key = "q", mods = "LEADER", action = act.QuickSelect },
	{ key = "s", mods = "LEADER", action = act.ShowLauncher },

	-- ── Lazygit (LEADER+g) ────────────────────────────────────────────
	-- {
	-- 	key = "g",
	-- 	mods = "LEADER",
	-- 	action = act.SpawnCommandInNewTab({
	-- 		args = { "lazygit" },
	-- 		cwd = wezterm.home_dir, -- ou remova essa linha pra abrir no cwd do pane atual
	-- 	}),
	-- },	

	-- LEADER+Q → só coisas git (hash + branch)
	{
	  key = "g",
	  mods = "LEADER", -- |SHIFT
	  action = act.QuickSelectArgs({
	    label = "git",
	    patterns = {
	      [[\b[0-9a-f]{7,40}\b]],
	      [[\b(?:main|master|develop|feature|fix|hotfix|release)/[\w./-]+\b]],
	      [[\b(?:feature|fix|hotfix|release)/[\w./-]+\b]],
	    },
	  }),
	},
	
	-- LEADER+G → só paths Go / module paths (se quiser separado do lazygit)
	-- (cuidado: você já usa LEADER+g pro lazygit)	

	-- ── Ir para dotfiles (LEADER+c) ──────────────────────────────────
	{
		key = "c",
		mods = "LEADER",
		action = act.SpawnCommandInNewTab({
			cwd = wezterm.home_dir .. "/dotfiles",
		}),
	},	
}

-- ── Trocar de aba por número (LEADER + 1..9) ────────────────────────
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1), -- índice começa em 0
	})
end

-- Copy/Paste — platform-aware
if IS_MACOS then
	table.insert(config.keys, { key = "c", mods = "CMD", action = act.CopyTo("Clipboard") })
	table.insert(config.keys, { key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") })
	table.insert(config.keys, { key = "=", mods = "CMD", action = act.IncreaseFontSize })
	table.insert(config.keys, { key = "-", mods = "CMD", action = act.DecreaseFontSize })
	table.insert(config.keys, { key = "0", mods = "CMD", action = act.ResetFontSize })
else
	table.insert(config.keys, { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") })
	table.insert(config.keys, { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") })
	table.insert(config.keys, { key = "=", mods = "CTRL", action = act.IncreaseFontSize })
	table.insert(config.keys, { key = "-", mods = "CTRL", action = act.DecreaseFontSize })
	table.insert(config.keys, { key = "0", mods = "CTRL", action = act.ResetFontSize })
end

-- ── MOUSE BINDINGS ────────────────────────────────────────────────────

config.mouse_bindings = {
	-- Cmd/Ctrl + left click → open hyperlink
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = IS_MACOS and "CMD" or "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
	-- Right-click → paste
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = act.PasteFrom("Clipboard"),
	},
}

-- ══════════════════════════════════════════════════════════════════════
return config
