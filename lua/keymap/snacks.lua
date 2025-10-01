local bind = require("keymap.bind")
local map_callback = bind.map_callback

local plug_map = {
	-- Explorer
	["n|<leader>e"] = map_callback(function()
			Snacks.explorer()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("explorer: File Explorer"),
	-- Other
	["n|<leader>z"] = map_callback(function()
			Snacks.zen()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("ui: Toggle Zen Mode"),
	["n|<leader>Z"] = map_callback(function()
			Snacks.zen.zoom()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("ui: Toggle Zoom"),
	["n|<leader>."] = map_callback(function()
			Snacks.scratch()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("buffer: Toggle Scratch Buffer"),
	["n|<leader>S"] = map_callback(function()
			Snacks.scratch.select()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("buffer: Select Scratch Buffer"),
	["n|Q"] = map_callback(function()
			Snacks.bufdelete()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("buffer: Delete Buffer"),
	["n|<leader>cR"] = map_callback(function()
			Snacks.rename.rename_file()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("file: Rename File"),
	["nv|<leader>gB"] = map_callback(function()
			Snacks.gitbrowse()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("git: Browse in browser"),
	["n|<leader>gg"] = map_callback(function()
			Snacks.lazygit()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("git: Open Lazygit"),
	["n|<leader>un"] = map_callback(function()
			Snacks.notifier.hide()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("ui: Dismiss all notifications"),
	["n|<c-/>"] = map_callback(function()
			Snacks.terminal()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("terminal: Toggle terminal"),
	["n|<c-_>"] = map_callback(function()
			Snacks.terminal()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("terminal: Toggle terminal"),
	-- Navigation
	["nt|]]"] = map_callback(function()
			Snacks.words.jump(vim.v.count1)
		end)
		:with_noremap()
		:with_silent()
		:with_desc("nav: Next reference"),
	["nt|[["] = map_callback(function()
			Snacks.words.jump(-vim.v.count1)
		end)
		:with_noremap()
		:with_silent()
		:with_desc("nav: Previous reference"),
	-- Neovim News
	["n|<leader>N"] = map_callback(function()
			Snacks.win({
				file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
				width = 0.6,
				height = 0.6,
				wo = {
					spell = false,
					wrap = false,
					signcolumn = "yes",
					statuscolumn = " ",
					conceallevel = 3,
				},
			})
		end)
		:with_noremap()
		:with_silent()
		:with_desc("help: Neovim News"),
}

bind.nvim_load_mapping(plug_map)
