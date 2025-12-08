local bind = require("keymap.bind")
local map_cr = bind.map_cr
-- local map_cu = bind.map_cu
-- local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local plug_map = {
	-- Plugin MarkdownPreview
	["n|<F12>"] = map_cr("MarkdownPreviewToggle"):with_noremap():with_silent():with_desc("tool: Preview markdown"),

	-- Plugin refactoring.nvim
	["x|<leader>re"] = map_callback(function()
			require("refactoring").refactor("Extract Function")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Extract Function"),
	["x|<leader>rf"] = map_callback(function()
			require("refactoring").refactor("Extract Function To File")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Extract Function To File"),
	["x|<leader>rv"] = map_callback(function()
			require("refactoring").refactor("Extract Variable")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Extract Variable"),
	["n|<leader>rI"] = map_callback(function()
			require("refactoring").refactor("Inline Function")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Inline Function"),
	["n|<leader>ri"] = map_callback(function()
			require("refactoring").refactor("Inline Variable")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Inline Variable"),
	["x|<leader>ri"] = map_callback(function()
			require("refactoring").refactor("Inline Variable")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Inline Variable"),
	["n|<leader>rb"] = map_callback(function()
			require("refactoring").refactor("Extract Block")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Extract Block"),
	["n|<leader>rbf"] = map_callback(function()
			require("refactoring").refactor("Extract Block To File")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Extract Block To File"),
	-- Prompt for refactor to select from the list
	["x|<leader>rr"] = map_callback(function()
			require("refactoring").select_refactor()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Select Refactor"),
	["n|<leader>rr"] = map_callback(function()
			require("refactoring").select_refactor()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("refactor: Select Refactor"),
}

bind.nvim_load_mapping(plug_map)
