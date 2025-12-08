local lang = {}

lang["iamcco/markdown-preview.nvim"] = {
	lazy = true,
	ft = "markdown",
	build = ":call mkdp#util#install()",
}
lang["phelipetls/jsonpath.nvim"] = {
	lazy = true,
	ft = "json",
}
lang["ThePrimeagen/refactoring.nvim"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = require("lang.refactoring"),
}
return lang
