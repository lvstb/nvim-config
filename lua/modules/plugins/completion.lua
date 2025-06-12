local completion = {}

completion["b0o/schemastore.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
}

completion["saghen/blink.cmp"] = {
	dependencies = {
		"rafamadriz/friendly-snippets",
		"saghen/blink.compat",
		"onsails/lspkind.nvim",
		"giuxtaposition/blink-cmp-copilot",
	},
	version = "*",
	config = require("completion.blink"),
}

completion["stevearc/conform.nvim"] = {
	lazy = true,
	event = { "CursorHold", "CursorHoldI" },
	config = require("completion.formatter"),
}
completion["mfussenegger/nvim-lint"] = {
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = require("completion.linter"),
}
completion["dnlhc/glance.nvim"] = {
	lazy = true,
	event = "LspAttach",
	config = require("completion.glance"),
}

completion["zbirenbaum/copilot.lua"] = {
	lazy = true,
	cmd = "Copilot",
	event = "InsertEnter",
	config = require("completion.copilot"),
	dependencies = {
		{
			"zbirenbaum/copilot-cmp",
			config = require("completion.copilot-cmp"),
		},
	},
}

return completion
