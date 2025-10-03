local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local plug_map = {
	-- Next Edit Suggestions (NES) keymaps
	["n|<Tab>"] = map_callback(function()
			if not require("sidekick").nes_jump_or_apply() then
				return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
			end
		end)
		:with_expr()
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Jump/Apply Next Edit"),

	["n|<leader>an"] = map_callback(function()
			require("sidekick.nes").update()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Update NES suggestions"),

	["n|<leader>aj"] = map_callback(function()
			require("sidekick.nes").jump()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Jump to next edit"),

	["n|<leader>aa"] = map_callback(function()
			require("sidekick.nes").apply()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Apply all edits"),

	["n|<leader>ax"] = map_callback(function()
			require("sidekick").clear()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Clear suggestions"),

	["n|<leader>ae"] = map_cr("Sidekick nes toggle")
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Toggle NES enabled"),

	-- AI CLI Integration keymaps
	["n|<leader>at"] = map_callback(function()
			require("sidekick.cli").toggle({ focus = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Toggle AI CLI"),

	["n|<leader>as"] = map_callback(function()
			require("sidekick.cli").select({ filter = { installed = true } })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Select AI tool"),

	["n|<leader>ap"] = map_callback(function()
			require("sidekick.cli").prompt()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Select prompt"),

	["x|<leader>ap"] = map_callback(function()
			require("sidekick.cli").prompt()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Send prompt with selection"),

	["n|<leader>av"] = map_callback(function()
			require("sidekick.cli").send({ msg = "{position}", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Send current position"),

	["x|<leader>av"] = map_callback(function()
			require("sidekick.cli").send({ msg = "{selection}", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Send selection"),

	["n|<leader>af"] = map_callback(function()
			require("sidekick.cli").send({ msg = "{file}", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Send current file"),

	["n|<leader>ad"] = map_callback(function()
			require("sidekick.cli").send({ prompt = "diagnostics", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Fix diagnostics"),

	["n|<leader>ar"] = map_callback(function()
			require("sidekick.cli").send({ prompt = "review", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Review file"),

	["n|<leader>ao"] = map_callback(function()
			require("sidekick.cli").send({ prompt = "optimize", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Optimize code"),

	["n|<leader>aw"] = map_callback(function()
			require("sidekick.cli").send({ prompt = "tests", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Write tests"),

	-- Focus switching for all modes
	["n|<C-.>"] = map_callback(function()
			require("sidekick.cli").focus()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Switch focus"),

	["x|<C-.>"] = map_callback(function()
			require("sidekick.cli").focus()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Switch focus"),

	["i|<C-.>"] = map_callback(function()
			require("sidekick.cli").focus()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Switch focus"),

	["t|<C-.>"] = map_callback(function()
			require("sidekick.cli").focus()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Switch focus"),

	-- Quick access to specific AI tools
	["n|<leader>ac"] = map_callback(function()
			require("sidekick.cli").toggle({ name = "claude", focus = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Toggle Claude"),

	["n|<leader>ag"] = map_callback(function()
			require("sidekick.cli").toggle({ name = "opencode", focus = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Toggle OpenCode"),

	["n|<leader>ah"] = map_callback(function()
			require("sidekick.cli").hide()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Hide CLI window"),

	-- Send "this" context (position or selection based on mode)
	["n|<leader>ai"] = map_callback(function()
			require("sidekick.cli").send({ msg = "{this}", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Send this context"),

	["x|<leader>ai"] = map_callback(function()
			require("sidekick.cli").send({ msg = "{this}", submit = true })
		end)
		:with_noremap()
		:with_silent()
		:with_desc("sidekick: Send this selection"),
}

bind.nvim_load_mapping(plug_map)