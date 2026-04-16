local function find_copilot_lsp()
	local possible_cmds = {
		"copilot-language-server",
		"github-copilot-lsp",
		"copilot_language_server",
	}

	for _, cmd in ipairs(possible_cmds) do
		if vim.fn.executable(cmd) == 1 then
			return { cmd, "--stdio" }
		end
	end

	local home = vim.fn.expand("~")
	local local_copilot = home .. "/node_modules/.bin/copilot-language-server"
	if vim.fn.executable(local_copilot) == 1 then
		return { "node", local_copilot, "--stdio" }
	end
end

local cmd = find_copilot_lsp()

return {
	cmd = cmd or function() end,
	root_dir = function(_, on_dir)
		if cmd then
			on_dir(vim.fn.getcwd())
		end
	end,
	single_file_support = true,
	settings = {},
}
