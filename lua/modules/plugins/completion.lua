local completion = {}

completion["saghen/blink.cmp"] = {
	dependencies = {
		"rafamadriz/friendly-snippets",
		"saghen/blink.compat",
		"onsails/lspkind.nvim",
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
}
completion["folke/sidekick.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = function()
		require("completion.sidekick")
	end,
	dependencies = {
		"folke/snacks.nvim", -- for better prompt selection
		"nvim-treesitter/nvim-treesitter-textobjects", -- for function/class context
	},
}
completion["b0o/schemastore.nvim"] = {
	lazy = true,
}

return completion
