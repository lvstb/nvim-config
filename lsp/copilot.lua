-- Check if we have the copilot language server available
local function find_copilot_lsp()
	-- Try different possible locations for the copilot language server
	local possible_cmds = {
		"copilot-language-server",
		"github-copilot-lsp", 
		"copilot_language_server",
	}
	
	-- Check system binaries
	for _, cmd in ipairs(possible_cmds) do
		if vim.fn.executable(cmd) == 1 then
			return { cmd, "--stdio" }
		end
	end
	
	-- Check local npm installation
	local home = vim.fn.expand("~")
	local local_copilot = home .. "/node_modules/.bin/copilot-language-server"
	if vim.fn.executable(local_copilot) == 1 then
		return { "node", local_copilot, "--stdio" }
	end
	
	-- If we can't find the LSP server, return nil to disable this LSP
	return nil
end

local cmd = find_copilot_lsp()
if not cmd then
	-- No Copilot LSP server found, return nil to disable
	return nil
end

return {
	cmd = cmd,
	filetypes = {
		"*", -- Enable for all file types
	},
	root_dir = function(fname)
		return vim.fn.getcwd()
	end,
	single_file_support = true,
	settings = {
		-- Add any Copilot LSP specific settings here
	},
}