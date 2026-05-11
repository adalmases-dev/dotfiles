-- Fav default color schemes: catppuccin, habamax, unokai
vim.opt.termguicolors = true
vim.cmd.colorscheme("habamax")

-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.opt.number = true -- line number
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.wrap = false -- do not wrap lines by default
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.opt.tabstop = 2 -- tabwidth
vim.opt.shiftwidth = 2 -- indent width
vim.opt.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- copy indent from current line

vim.opt.ignorecase = true -- case insensitive search (if lowecase)
vim.opt.smartcase = true -- case sensitive search (if any uppercase in string)
vim.opt.hlsearch = true -- highlight search matches
vim.opt.incsearch = true -- show matches as you type

vim.opt.signcolumn = "yes" -- always show a sign column
vim.opt.colorcolumn = "100" -- show a column at 100 position chars
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.cmdheight = 1 -- single line command line
vim.opt.completeopt = "menu,menuone" -- completion options
vim.opt.complete:append("o") -- extra options
vim.opt.showmode = false -- do not show the mode, instead have it in statusline
vim.opt.pumheight = 5 -- popup menu height
vim.opt.pumblend = 10 -- popup menu transparency
vim.opt.winblend = 0 -- floating window transparency
vim.opt.conceallevel = 2 -- Obsidian requirement
vim.opt.concealcursor = "" -- do not hide cursorline in markup
vim.opt.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

-- undo dir
local undodir = vim.fn.expand("~/.local/state/nvim_undodir")
if
	vim.fn.isdirectory(undodir) == 0 -- create undodir if nonexistent
then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false -- do not create a backup file
vim.opt.writebackup = false -- do not write to a backup file
vim.opt.swapfile = false -- do not create a swapfile
vim.opt.undofile = true -- do create an undo file
vim.opt.undodir = undodir -- set the undo directory
vim.opt.updatetime = 200 -- faster completion
vim.opt.timeoutlen = 500 -- timeout duration for key combos
vim.opt.ttimeoutlen = 10 -- key code timeout
vim.opt.autoread = true -- auto-reload changes if edited outside of neovim
vim.opt.autowrite = false -- do not auto-save (I use format on save)

vim.opt.hidden = true -- allow hidden buffers
vim.opt.errorbells = false -- no error sounds
vim.opt.backspace = "indent,eol,start" -- better backspace behaviour
vim.opt.autochdir = false -- do not autochange directories
vim.opt.iskeyword:append("-") -- include - as part of a word
vim.opt.path:append("**") -- include subdirs in search
vim.opt.selection = "inclusive" -- include last char in selection
vim.opt.mouse = "a" -- enable mouse support
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.modifiable = true -- allow buffer modifications
vim.opt.encoding = "utf-8" -- set encoding

-- Folding: requires treesitter available at runtime; safe fallback if not
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

vim.opt.wildmenu = true -- tab completion
vim.opt.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.opt.redrawtime = 10000 -- increase neovim redraw tolerance
vim.opt.maxmempattern = 20000 -- increase max memory

-- ============================================================================
-- CUSTOM GOD STATUSLINE
-- ============================================================================

vim.opt.laststatus = 3 -- show only one pinned-to-the-bottom status bar

-- Git branch function with caching and Nerd Font icon
local cached_branch = ""
local last_check = 0
local function git_branch()
	local now = vim.loop.now()
	if now - last_check > 5000 then -- Check every 5 seconds
		cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
		last_check = now
	end
	if cached_branch ~= "" then
		return "󰘬 " .. cached_branch .. "  "
	end
	return ""
end

-- File type with Nerd Font icon
local function file_type()
	local ft = vim.bo.filetype
	local icons = {
		lua = " ",
		python = "󰌠 ",
		javascript = " ",
		typescript = " ",
		javascriptreact = "󰜈 ",
		typescriptreact = "󰜈 ",
		html = " ",
		css = " ",
		scss = " ",
		json = " ",
		markdown = " ",
		vim = " ",
		sh = " ",
		bash = " ",
		zsh = " ",
		rust = "󱘗 ",
		go = "󰟓 ",
		c = "󰙱 ",
		cpp = "󰙲 ",
		java = " ",
		php = "󰌟 ",
		ruby = " ",
		swift = "󰛥 ",
		kotlin = "󱈙 ",
		sql = " ",
		yaml = " ",
		toml = " ",
		xml = "󰗀 ",
		dockerfile = "󰡨 ",
		gitcommit = " ",
		gitconfig = " ",
	}

	if ft == "" then
		return "  "
	end

	return ((icons[ft] or "  ") .. ft)
end

-- Nvim mode
local function mode_icon()
	local mode = vim.fn.mode()
	local modes = {
		n = "   NORMAL",
		i = "   INSERT",
		v = " 󰅨 VISUAL",
		V = " 󰅨 V-LINE",
		["\22"] = " 󰅨 V-BLOCK",
		c = "  COMMAND",
		s = "  SELECT",
		S = "  S-LINE",
		["\19"] = "  S-BLOCK",
		R = "  REPLACE",
		r = "  REPLACE",
		["!"] = "  SHELL",
		t = "  TERMINAL",
	}
	return modes[mode] or ("  " .. mode)
end

local function file_status()
	local status = ""
	if vim.bo.modified then
		status = status .. " "
	end
	if vim.bo.readonly or not vim.bo.modifiable then
		status = status .. " "
	end
	return status
end

local function lsp_status()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return ""
	end
	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	return " " .. table.concat(names, ", ") .. "  "
end

local function diagnostics_status()
	if vim.diagnostic.is_enabled() then
		return "󰗠 diagnostics"
	end
	return "󰅙 diagnostics"
end

local function autoformat_status()
	if vim.g.disable_autoformat then
		return "󰅙 format"
	end
	return "󰗠 format"
end

_G.file_status = file_status
_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.lsp_status = lsp_status
_G.diagnostics_status = diagnostics_status
_G.autoformat_status = autoformat_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

local function setup_dynamic_statusline()
	local function get_statusline()
		if vim.bo.filetype == "NvimTree" then
			return "%#StatusLineBold#   Explorer %*"
		end

		return table.concat({
			"  ",
			"%#StatusLineBold#",
			"%{v:lua.mode_icon()}",
			"%#StatusLine#",
			"  ",
			"%{v:lua.git_branch()}", -- adds the final  if git branch is detected
			"%f %{v:lua.file_status()}",
			"  ",
			"%{v:lua.file_type()}",
			"  ",
			"%{v:lua.lsp_status()}", -- adds the final  if LSP is detected
			"%{v:lua.diagnostics_status()}",
			"  ",
			"%{v:lua.autoformat_status()}",
			"  ",
			"%=",
			"  %l:%c  ",
		})
	end

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "BufWinEnter", "FileType" }, {
		callback = function()
			vim.opt_local.statusline = get_statusline()
		end,
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		callback = function()
			if vim.bo.filetype == "NvimTree" then
				vim.opt_local.statusline = "%#StatusLineBold#   Explorer %*"
			else
				vim.opt_local.statusline = "  %f %h%m%r  %{v:lua.file_type()} %=  %l:%c  "
			end
		end,
	})
end

setup_dynamic_statusline()

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

-- Extra escapes
vim.keymap.set({ "i", "v" }, "kj", "<Esc>", { desc = "Exit", nowait = true })
vim.keymap.set({ "i", "v" }, "jk", "<Esc>", { desc = "Exit", nowait = true })

-- Save file
vim.keymap.set("n", "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Better up/down (for wrapped text)
vim.keymap.set({ "n", "x" }, "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set({ "n", "x" }, "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

-- Clear highlight
vim.keymap.set("n", "<Esc>", function()
	vim.cmd("nohlsearch")
	vim.fn.setreg("/", "")
	return "<Esc>"
end, { expr = true, desc = "Clear highlights and search pattern" })

-- Search results and scroll centered
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Join lines without moving cursor
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines keeping cursor position" })

-- Paste/Delete enhanced options
vim.keymap.set("n", "<C-c>", "<cmd>%y+<CR><esc>", { desc = "Copy Whole File" })
vim.keymap.set("x", "p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "x" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
vim.keymap.set({ "n", "x" }, "x", '"_x', { desc = "Delete char without yanking" })
vim.keymap.set(
	"v",
	"<LeftRelease>",
	'<LeftRelease>"*ygv',
	{ desc = "Yank mouse‐selection to Primary Selection Register" }
)

-- Move lines
vim.keymap.set("n", "<C-S-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<C-S-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
vim.keymap.set("i", "<C-S-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
vim.keymap.set("i", "<C-S-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("v", "<C-S-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<C-S-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Buffers
vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bprev<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>x", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local win_id = vim.api.nvim_get_current_win()
	local loaded_buffers = vim.fn.getbufinfo({ buflisted = 1 })
	local windows_with_buffer = 0
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			windows_with_buffer = windows_with_buffer + 1
		end
	end
	-- If Buffer is in multiple windows -> Just close the window
	if windows_with_buffer > 1 then
		vim.api.nvim_win_close(win_id, false)
		return
	end
	-- If Only one window has it, but other buffers exist -> Switch then kill
	if #loaded_buffers > 1 then
		vim.cmd("bprevious")
		vim.cmd("confirm bdelete " .. bufnr)
	else
		-- If Last buffer in the last window -> Switch to empty scratch
		local scratch = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(scratch, "buftype", "nofile")
		vim.api.nvim_buf_set_option(scratch, "bufhidden", "wipe")
		vim.api.nvim_buf_set_option(scratch, "modifiable", false)
		vim.api.nvim_win_set_buf(win_id, scratch)
		vim.cmd("confirm bdelete " .. bufnr)
	end
end, { desc = "Smart Exit Buffer" })

-- Window
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window", remap = true })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<leader>b", ":vsplit<CR>", { desc = "Split window on the horizontal direction" })
vim.keymap.set("n", "<leader>v", ":split<CR>", { desc = "Split window on the vertical direction" })
vim.keymap.set("n", "<leader>wx", function()
	local wins = vim.api.nvim_tabpage_list_wins(0)
	local tabs = vim.api.nvim_list_tabpages()
	if #wins > 1 then
		vim.cmd("close")
		return
	end
	if #tabs > 1 then
		vim.cmd("tabclose")
		return
	end
end, { desc = "Smart Exit Window" })

-- Tabs
vim.keymap.set("n", "<tab>", "<cmd>tabnext<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "<S-tab>", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Exit Tab" })

-- Comment
vim.keymap.set("n", "<C-S-7>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<C-S-7>", "gc", { remap = true, desc = "Toggle comment selection" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Toggle diagnostics
vim.keymap.set("n", "td", function()
	local is_enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not is_enabled)
	if is_enabled then
		print("Diagnostics Disabled")
	else
		print("Diagnostics Enabled")
	end
	vim.cmd("redrawstatus")
end, { desc = "Toggle diagnostics" })

-- Toggle autoformat-on-save behaviour
vim.keymap.set("n", "tf", function()
	if vim.g.disable_autoformat then
		vim.g.disable_autoformat = false
		print("Format-on-save Disabled")
	else
		vim.g.disable_autoformat = true
		print("Format-on-save Enabled")
	end
	vim.cmd("redrawstatus")
end, { desc = "Toggle format-on-save" })

-- Force autoformat (no-saving)
vim.keymap.set("n", "ff", function()
	require("conform").format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 500,
	})
end, { desc = "Format File" })

-- quit
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- ===========================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Return to last cursor position before closing file
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- Force wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- Update custom status line
vim.api.nvim_create_autocmd("ModeChanged", {
	callback = function()
		vim.cmd("redrawstatus")
	end,
})
-- ============================================================================
-- PLUGINS (vim.pack v0.12+)
-- ============================================================================
-- Installed at ~/.local/share/nvim/site/pack/core/opt/

vim.pack.add({
	-- File Navigation and UI
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	"https://www.github.com/akinsho/bufferline.nvim",
	"https://www.github.com/tiagovla/scope.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	-- Syntax highlighting
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	-- Completion
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	-- Other tools
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/akinsho/toggleterm.nvim",
	-- "https://github.com/folke/trouble.nvim" -- Diagnostics
	-- "https://github.com/rcarriga/nvim-dap-ui" -- Debugger
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim", -- Mason - LSPs
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", -- Mason - Formatters/Linters
	"https://github.com/stevearc/conform.nvim", -- Formatter
})

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

-- Nvim Tree (file explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set custom tree keymaps
local function custom_tree_keymaps(bufnr)
	local api = require("nvim-tree.api")
	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "t", api.node.open.tab, opts("Open New Tab"))
	vim.keymap.set("n", "v", api.node.open.horizontal, opts("Open Split Window (vertical ↓ direction)"))
	vim.keymap.set("n", "b", api.node.open.vertical, opts("Open Split Window (besides → direction)"))
	vim.keymap.set("n", "i", api.node.show_info_popup, opts("Toggle File Info Popup"))
	vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
	vim.keymap.set({ "n", "x" }, "c", api.fs.copy.node, opts("Copy"))
	vim.keymap.set({ "n", "x" }, "x", api.fs.cut, opts("Cut"))
	vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
	vim.keymap.set({ "n", "x" }, "d", api.fs.trash, opts("Trash"))
	vim.keymap.set({ "n", "x" }, "D", api.fs.remove, opts("Delete"))
	vim.keymap.set("n", "<Tab>", function()
		local node = api.tree.get_node_under_cursor()
		if node.type == "directory" and not node.open then
			api.node.open.edit()
		else
			api.node.navigate.parent_close()
		end
	end, opts("Smart Toggle Expand/Collapse"))
	vim.keymap.set("n", "w", api.tree.collapse_all, opts("Collapse All"))
	vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
	vim.keymap.set("n", "R", api.fs.rename_full, opts("Rename: Full Path"))
	vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
	vim.keymap.set("n", "yy", api.fs.copy.relative_path, opts("Copy Relative Path"))
	vim.keymap.set("n", "yyy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
	vim.keymap.set("n", "h", api.tree.toggle_help, opts("Help"))
	vim.keymap.set("n", "q", api.tree.close, opts("Close"))
	-- vim.keymap.set("n",          "s",              api.filter.live.start,              opts("Live Search Filter"))
	-- vim.keymap.set("n",          "<esc>",          api.filter.live.clear,              opts("Clear Filter"))
end

require("nvim-tree").setup({
	on_attach = custom_tree_keymaps,
	hijack_cursor = true,
	view = {
		width = 35,
		side = "right",
	},
	renderer = {
		root_folder_label = false,
		group_empty = true,
		indent_markers = {
			enable = true,
		},
		-- I prefer colors to icons
		highlight_git = true,
		icons = {
			show = {
				git = false,
			},
		},
	},
	update_focused_file = {
		enable = true,
		update_root = false,
	},
	diagnostics = {
		enable = false,
	},
	filters = {
		dotfiles = false, -- false = show dotfiles
		custom = { "^.git$", "__pycache__" },
	},
	actions = {
		open_file = {
			window_picker = {
				enable = true,
			},
		},
	},
})

vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

-- Bufferline and Scope
require("scope").setup()
require("bufferline").setup({
	options = {
		mode = "buffers",
		diagnostics = false,
	},
	highlights = {
		buffer_selected = {
			bold = true,
			italic = false,
		},
	},
})

-- Fzf
require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "Fzf Files" })

vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "Fzf Buffers" })

vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "Fzf Live Grep" })

vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "Fzf Help Tags" })

-- Treesitter (sytnax highlighting)
local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})

	local ensure_installed = {
		"c",
		"cpp",
		"python",
		"rust",
		"cmake",
		"xml",
		"yaml",
		"bash",
		"dockerfile",
		"lua",
		"vim",
		"vimdoc",
		"markdown",
		"markdown_inline",
		"json",
		"html",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local parsers_to_install = {}
	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end
	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end
	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

-- Blink completion
require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<CR>"] = { "accept", "fallback" },
		["<C-e>"] = { "hide", "fallback" },

		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-k>"] = { "scroll_documentation_up", "fallback" },
		["<C-j>"] = { "scroll_documentation_down", "fallback" },
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	completion = {
		list = { selection = { preselect = true, auto_insert = false } },
		documentation = { auto_show = true, auto_show_delay_ms = 1000 },
		ghost_text = { enabled = true },
		menu = {
			draw = {
				columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
			},
		},
	},
	signature = { enabled = true }, -- Show function signatures as you type
})

-- Other tools
require("which-key").setup({})

require("toggleterm").setup({
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	open_mapping = [[<C-S-ñ>]], -- Global toggle key
	hide_numbers = true,
	-- shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	terminal_mappings = true,
	persist_size = true,
	direction = "horizontal",

	-- 	float_opts = {
	-- 		border = "curved",
	-- 		winblend = 3,
	-- 		highlights = {
	-- 			border = "Normal",
	-- 			background = "Normal",
	-- 		},
	-- 	},
})

-- Terminal Navigation Integration: use <C-h/j/k/l> to move out of the terminal just like a window
function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "kj", [[<C-\><C-n>]], opts)
	vim.keymap.set("t", "<C-h>", [[<維-n><C-w>h]], opts)
	vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
	vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
	vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
end
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*",
	callback = function()
		set_terminal_keymaps()
	end,
})

-- ============================================================================
-- LSP, Linting, Formatting, Completion & Diagnostics
-- ============================================================================
require("mason").setup({})

-- Install & enable LSPs
local lsp_to_use = {
	"lua_ls",
	"basedpyright",
	"bashls",
	"clangd",
	"rust_analyzer",
}

require("mason-lspconfig").setup({
	ensure_installed = lsp_to_use,
	automatic_installation = true,
})

-- specific configs before enable
vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })

vim.lsp.enable(lsp_to_use)

-- Install linters & formaters
require("mason-tool-installer").setup({
	ensure_installed = {
		-- Linters: Not using them, feel like it kills my flow! "shellcheck", "flake8", "cpplint", etc
		-- Formatters:
		"shfmt",
		"fixjson",
		"clang-format",
		"black",
		"isort",
		"prettierd",
		"stylua",
	},
})

-- Setup formaters
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" }, -- chained formatting: isort runs first, then black
		json = { "fixjson" },
		markdown = { "prettierd" },
		rust = { "rustfmt" }, --system binary at ~/.cargo/bin
		sh = { "shfmt" },
		bash = { "shfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
	},
	format_on_save = function()
		if vim.g.disable_autoformat then
			return
		end
		return {
			timeout_ms = 500,
			lsp_format = "fallback", -- Use LSP if no formatter is found
		}
	end,
})

-- LSP diagnostics
vim.diagnostic.config({
	virtual_text = false,
	signs = false,
	underline = true,
	-- float = {
	--   source = true,
	-- }
})

-- do
-- 	local orig = vim.lsp.util.open_floating_preview
-- 	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
-- 		opts = opts or {}
-- 		return orig(contents, syntax, opts, ...)
-- 	end
-- end

local function lsp_on_attach(ev)
	local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

	local bufnr = ev.buf
	local function opts(desc)
		return { desc = "LSP: " .. desc, buffer = bufnr, noremap = true, silent = true }
	end

	vim.keymap.set("n", "<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts("Goto Definition (Fzf)"))

	vim.keymap.set("n", "<leader>gD", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts("Goto Definition (Split)"))

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))

	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename Symbol"))

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts("Line Diagnostics"))

	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts("Next Diagnostic"))

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts("Previous Diagnostic"))

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))

	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts("Find References"))

	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts("Find Type Definition"))

	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts("Find Document Symbols"))

	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts("Find Workspace Symbols"))

	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts("Find Implementations"))

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts("Organize Imports"))
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
