return function()
	local rainbow_delimiters = require("rainbow-delimiters")
	require("rainbow-delimiters.setup")({ -- This module contains a number of default definitions
		strategy = {
			[""] = rainbow_delimiters.strategy["global"],
			vim = rainbow_delimiters.strategy["local"],
		},
		condition = function(bufnr)
			local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
			if not lang then
				return false
			end

			-- Some custom filetypes map to a Treesitter language name without an installed parser.
			local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
			return ok and parser ~= nil
		end,
		query = {
			[""] = "rainbow-delimiters",
			lua = "rainbow-blocks",
		},
		-- highlight = {
		-- 	"RainbowDelimiterRed",
		-- 	"RainbowDelimiterYellow",
		-- 	"RainbowDelimiterBlue",
		-- 	"RainbowDelimiterOrange",
		-- 	"RainbowDelimiterGreen",
		-- 	"RainbowDelimiterViolet",
		-- 	"RainbowDelimiterCyan",
		-- },
	})
end
