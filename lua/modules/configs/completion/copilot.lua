return function()
	vim.defer_fn(function()
		require("copilot").setup({
			-- I don't find the panel useful.
			panel = { enabled = false },
			suggestion = {
				enabled = true,
				auto_trigger = true,
				-- Use alt to interact with Copilot.
				keymap = {
					-- Re-enable accept since we're not using nvim-cmp integration
					accept = "<M-a>",
					accept_word = "<M-w>",
					accept_line = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "/",
				},
			},
			filetypes = {
				markdown = true,
				help = false,
				gitcommit = false,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
			},
			copilot_node_command = "node", -- Node.js version must be > 18.x
			server_opts_overrides = {},
		})
	end, 100)
end
