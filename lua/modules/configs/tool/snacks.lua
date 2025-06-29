return function()
	require("snacks").setup({
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = true },
		indent = {
			enabled = true,
			char = "│", -- matches your char[1]
			only_scope = false,
			only_current = false,
			hl = "SnacksIndent", -- equivalent to your IblIndent
			priority = 1,
			-- Scope configuration (equivalent to your scope settings)
			scope = {
				enabled = true,
				char = "┃", -- matches your char[2] for scope
				hl = "SnacksIndentScope", -- equivalent to your IblScope
				priority = 200,
				underline = false,
				only_current = false,
			},
			-- Animation settings
			animate = {
				enabled = vim.fn.has("nvim-0.10") == 1,
				style = "out",
				easing = "linear",
				duration = {
					step = 20,
					total = 500,
				},
			},
			-- Filter equivalent to your exclude settings
			filter = function(buf)
				local excluded_filetypes = {
					"NvimTree",
					"TelescopePrompt",
					"dashboard",
					"dotooagenda",
					"flutterToolsOutline",
					"fugitive",
					"git",
					"gitcommit",
					"help",
					"json",
					"log",
					"markdown",
					"peekaboo",
					"startify",
					"todoist",
					"txt",
					"vimwiki",
					"vista",
				}
				local excluded_buftypes = {
					"terminal",
					"nofile",
				}

				local ft = vim.bo[buf].filetype
				local bt = vim.bo[buf].buftype

				-- Check if filetype or buftype is excluded
				for _, excluded_ft in ipairs(excluded_filetypes) do
					if ft == excluded_ft then
						return false
					end
				end

				for _, excluded_bt in ipairs(excluded_buftypes) do
					if bt == excluded_bt then
						return false
					end
				end

				return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
			end,
		},
		input = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		picker = {
			enabled = false, -- you disabled this
		},
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = {
			notification = {
				-- wo = { wrap = true } -- Wrap notifications
			},
		},
	})

	-- Create toggle mappings
	Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
	Snacks.toggle.diagnostics():map("<leader>ud")
	Snacks.toggle.line_number():map("<leader>ul")
	Snacks.toggle
		.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
		:map("<leader>uc")
	Snacks.toggle.treesitter():map("<leader>uT")
	Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
	Snacks.toggle.inlay_hints():map("<leader>uh")
	Snacks.toggle.indent():map("<leader>ug")
	Snacks.toggle.dim():map("<leader>uD")
end
