return function()
	local nts = require("nvim-treesitter")
	local group = vim.api.nvim_create_augroup("NvimTreesitterSetup", { clear = true })

	-- Optional setup; default install_dir is fine but we mirror the previous explicit value.
	nts.setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	-- Parsers to ensure are installed. Add/remove as needed.
	-- This runs asynchronously and is a no-op for parsers already present.
	nts.install({
		"bash",
		"c",
		"cpp",
		"css",
		"diff",
		"dockerfile",
		"go",
		"gomod",
		"gosum",
		"html",
		"javascript",
		"json",
		"jsonc",
		"lua",
		"luadoc",
		"luap",
		"markdown",
		"markdown_inline",
		"nix",
		"python",
		"query",
		"regex",
		"rust",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
	})

	-- Enable treesitter features per-buffer on FileType.
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.tbl_contains({ "vim" }, args.match) then
				return
			end

			local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, args.buf, "bigfile_disable_treesitter")
			if ok and is_large_file then
				return
			end

			local lang = vim.treesitter.language.get_lang(args.match) or args.match
			local has_parser = vim.treesitter.language.add(lang)
			if not has_parser then
				return
			end

			vim.treesitter.start(args.buf, lang)
			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo[0][0].foldmethod = "expr"
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})

	-- nvim-treesitter-textobjects (main branch) requires its own setup.
	require("nvim-treesitter-textobjects").setup({
		select = {
			lookahead = true,
		},
		move = {
			set_jumps = true,
		},
	})

	local select = require("nvim-treesitter-textobjects.select")
	local move = require("nvim-treesitter-textobjects.move")
	local map = vim.keymap.set

	map({ "x", "o" }, "af", function()
		select.select_textobject("@function.outer", "textobjects")
	end)
	map({ "x", "o" }, "if", function()
		select.select_textobject("@function.inner", "textobjects")
	end)
	map({ "x", "o" }, "ac", function()
		select.select_textobject("@class.outer", "textobjects")
	end)
	map({ "x", "o" }, "ic", function()
		select.select_textobject("@class.inner", "textobjects")
	end)

	map({ "n", "x", "o" }, "][", function()
		move.goto_next_start("@function.outer", "textobjects")
	end)
	map({ "n", "x", "o" }, "]m", function()
		move.goto_next_start("@class.outer", "textobjects")
	end)
	map({ "n", "x", "o" }, "]]", function()
		move.goto_next_end("@function.outer", "textobjects")
	end)
	map({ "n", "x", "o" }, "]M", function()
		move.goto_next_end("@class.outer", "textobjects")
	end)
	map({ "n", "x", "o" }, "[[", function()
		move.goto_previous_start("@function.outer", "textobjects")
	end)
	map({ "n", "x", "o" }, "[m", function()
		move.goto_previous_start("@class.outer", "textobjects")
	end)
	map({ "n", "x", "o" }, "[]", function()
		move.goto_previous_end("@function.outer", "textobjects")
	end)
	map({ "n", "x", "o" }, "[M", function()
		move.goto_previous_end("@class.outer", "textobjects")
	end)
end
