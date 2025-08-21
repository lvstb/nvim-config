return function()
	require("illuminate").configure({
		providers = {
			"lsp",
			"treesitter",
			"regex",
		},
		delay = 100,
		filetypes_denylist = {
			"DoomInfo",
			"DressingSelect",
			"Outline",
			"TelescopePrompt",
			"Trouble",
			"alpha",
			"dashboard",
			"dirvish",
			"fugitive",
			"help",
			"lsgsagaoutline",
			"neogitstatus",
			"norg",
			"snacks_terminal",
		},
		under_cursor = false,
	})
end
