local gitsigns_bar = "▌"

local gitsigns_hl_pool = {
	GitSignsAdd = "DiagnosticOk",
	GitSignsChange = "DiagnosticWarn",
	GitSignsChangedelete = "DiagnosticWarn",
	GitSignsDelete = "DiagnosticError",
	GitSignsTopdelete = "DiagnosticError",
	GitSignsUntracked = "NonText",
}

local diag_signs_icons = {
	DiagnosticSignError = " ",
	DiagnosticSignWarn = " ",
	DiagnosticSignInfo = " ",
	DiagnosticSignHint = "",
	DiagnosticSignOk = " ",
}

local function get_sign_name(cur_sign)
	if cur_sign == nil then
		return nil
	end

	cur_sign = cur_sign[1]

	if cur_sign == nil then
		return nil
	end

	cur_sign = cur_sign.signs

	if cur_sign == nil then
		return nil
	end

	cur_sign = cur_sign[1]

	if cur_sign == nil then
		return nil
	end

	return cur_sign["name"]
end

local function mk_hl(group, sym)
	return table.concat({ "%#", group, "#", sym, "%*" })
end

local function get_name_from_group(bufnum, lnum, group)
	local cur_sign_tbl = vim.fn.sign_getplaced(bufnum, {
		group = group,
		lnum = lnum,
	})

	return get_sign_name(cur_sign_tbl)
end

local function get_gitsigns_extmark(bufnr, lnum)
	local namespaces = vim.api.nvim_get_namespaces()

	for _, ns_name in ipairs({ "gitsigns_signs_", "gitsigns_signs_staged" }) do
		local ns = namespaces[ns_name]
		if ns then
			local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { lnum - 1, 0 }, { lnum - 1, -1 }, {
				details = true,
				limit = 1,
			})
			local mark = marks[1]
			if mark and mark[4] and mark[4].sign_hl_group then
				return mark[4]
			end
		end
	end
end

_G.get_statuscol_gitsign = function(bufnr, lnum)
	local mark = get_gitsigns_extmark(bufnr, lnum)

	if mark ~= nil then
		return mk_hl(gitsigns_hl_pool[mark.sign_hl_group] or mark.sign_hl_group, gitsigns_bar)
	else
		return " "
	end
end

_G.get_statuscol_diag = function(bufnum, lnum)
	local cur_sign_nm = get_name_from_group(bufnum, lnum, "*")

	if cur_sign_nm ~= nil and vim.startswith(cur_sign_nm, "DiagnosticSign") then
		return mk_hl(cur_sign_nm, diag_signs_icons[cur_sign_nm])
	else
		return " "
	end
end

_G.get_statuscol = function()
	local str_table = {}

	local parts = {
		["diagnostics"] = "%{%v:lua.get_statuscol_diag(bufnr(), v:lnum)%}",
		["fold"] = "%C",
		["gitsigns"] = "%{%v:lua.get_statuscol_gitsign(bufnr(), v:lnum)%}",
		["num"] = "%{v:relnum?v:relnum:v:lnum}",
		["sep"] = "%=",
		["signcol"] = "%s",
		["space"] = " ",
	}

	local order = {
		"diagnostics",
		"sep",
		"num",
		"space",
		"gitsigns",
		"fold",
		"space",
	}

	for _, val in ipairs(order) do
		table.insert(str_table, parts[val])
	end

	return table.concat(str_table)
end

vim.opt.statuscolumn = "%!v:lua.get_statuscol()"
-- probe
-- probe
