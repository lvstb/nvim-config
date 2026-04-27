# nvim-treesitter `master` → `main` Migration Plan

**Goal:** Migrate `nvim-treesitter` (and `nvim-treesitter-textobjects`) from the legacy `master` branch to the new `main` branch, eliminating the `query_predicates.lua` crash triggered by `vim-matchup`'s treesitter integration on Neovim 0.12.

**Architecture:** The `main` branch is a full rewrite. It removes the `configs.setup({...})` module system entirely. Highlighting/folding/indent are enabled per-buffer via `vim.treesitter.start()` (already done in this config). Parsers are installed asynchronously via `require('nvim-treesitter').install({...})` instead of `ensure_installed`. The `textobjects` companion plugin moves to `require('nvim-treesitter-textobjects.<module>')` (hyphen-separated namespace) and requires its own `setup{}` call.

**Tech Stack:** Neovim 0.12.1, lazy.nvim, NixOS (system-wide `tree-sitter` CLI must come from nixpkgs).

---

## Pre-flight Notes & Assumptions

- Neovim version: 0.12.1 — meets `main` branch requirement (≥ 0.12.0). ✅
- `tree-sitter` CLI is **not** installed system-wide. The `main` branch needs it for parser generation. On NixOS, install via `environment.systemPackages = [ pkgs.tree-sitter ];` (or `home-manager`, or a temporary `nix shell nixpkgs#tree-sitter`).
- Current state: `nvim-treesitter` is on `master` (detached HEAD); `nvim-treesitter-textobjects` is pinned to `branch = "main"` in `editor.lua` but installed at a `master` commit (frozen). Lazy will rebuild on next sync.
- 313 parser `.so` files currently live in `~/.local/share/nvim/site/lazy/nvim-treesitter/parser/` (bundled by master). After migration these go away; you install only what you need into `~/.local/share/nvim/site/parser/`.
- Plugins that depend on treesitter and may break:
  - `vim-matchup` — the original culprit. Its `treesitter-matchup/internal.lua` calls `nvim-treesitter` query predicates that don't exist on `main`. **Action: disable matchup's TS integration.**
  - `nvim-treesitter-context` — uses `vim.treesitter` directly, should work.
  - `nvim-ts-autotag` — uses `vim.treesitter` directly, should work.
  - `nvim-treehopper` — uses `vim.treesitter`, should work.
  - `rainbow-delimiters.nvim` — uses `vim.treesitter`, should work.
  - `refactoring.nvim` — uses `vim.treesitter`, should work.
  - `noice.nvim` (via Snacks dashboard?) — incidental; affected only because matchup ran on its WinEnter.

**Files this plan will modify:**
- `lua/modules/plugins/editor.lua` — pin both plugins to `branch = "main"`, declare parser list
- `lua/modules/configs/editor/treesitter.lua` — drop `configs.setup`, switch textobjects API, install parsers
- `lua/core/init.lua` — disable `vim-matchup` treesitter engine
- (No changes needed) `lua/modules/plugins/lang.lua`, `lua/modules/plugins/completion.lua`

**Branch:** `treesitter-main-migration`

---

### Task 1: Branch + safety net

**Step 1:** Create a working branch.

```bash
git -C /home/lars/nvim-config checkout -b treesitter-main-migration
```

**Step 2:** Snapshot current lazy lockfile so we can roll back if needed.

```bash
cp /home/lars/nvim-config/lazy-lock.json /home/lars/nvim-config/lazy-lock.json.pre-ts-main
```

**Step 3:** Commit the snapshot.

```bash
git -C /home/lars/nvim-config add lazy-lock.json.pre-ts-main docs/plans/2026-04-27-nvim-treesitter-main-migration.md
git -C /home/lars/nvim-config commit -m "chore: snapshot lockfile before nvim-treesitter main migration"
```

---

### Task 2: Install `tree-sitter` CLI system-wide

**Files:** `/etc/nixos/configuration.nix` (or your home-manager file)

**Step 1:** Add `pkgs.tree-sitter` to `environment.systemPackages`. **You will do this manually** — I shouldn't edit `/etc/nixos/`.

**Step 2:** Rebuild.

```bash
sudo nixos-rebuild switch
```

**Step 3:** Verify.

```bash
which tree-sitter && tree-sitter --version
```

Expected: version ≥ 0.26.1.

**Alternative (transient, for testing only):** `nix shell nixpkgs#tree-sitter` before launching nvim.

---

### Task 3: Disable `vim-matchup` treesitter integration

**Files:**
- Modify: `lua/core/init.lua:62` (extend the matchup section)

**Step 1:** Add the disable flag immediately after `vim.g.matchup_matchparen_deferred = 1`.

```lua
-- vim-matchup's treesitter engine calls nvim-treesitter master-only
-- query predicates that no longer exist on `main` (and that crash on
-- Neovim 0.12). Force matchup to use its built-in regex engine.
vim.g.matchup_treesitter_enabled = 0
```

**Step 2:** Save and verify the file parses.

```bash
nvim --headless -c "luafile lua/core/init.lua" -c "qa" 2>&1
```

Expected: no errors (silent exit).

**Step 3:** Commit.

```bash
git add lua/core/init.lua
git commit -m "fix(matchup): disable treesitter engine to avoid query_predicates crash"
```

---

### Task 4: Switch plugin spec to `main` branch

**Files:**
- Modify: `lua/modules/plugins/editor.lua:45-50`

**Step 1:** Pin `nvim-treesitter` to `branch = "main"` and ensure `textobjects` stays on main.

Replace lines 45-50:

```lua
editor["nvim-treesitter/nvim-treesitter"] = {
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = require("editor.treesitter"),
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
		{ "nvim-treesitter/nvim-treesitter-context" },
```

**Step 2:** Do **not** sync lazy yet — config still uses old API. Move on to Task 5.

---

### Task 5: Rewrite `treesitter.lua` for `main` API

**Files:**
- Modify: `lua/modules/configs/editor/treesitter.lua` (full rewrite)

**Step 1:** Replace the entire file with the `main`-compatible version below.

```lua
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
```

Key differences from the original:
- `require("nvim-treesitter").setup({...})` instead of `require("nvim-treesitter.configs").setup({...})`
- Explicit `install({...})` call replaces `ensure_installed`
- `require("nvim-treesitter-textobjects").setup({...})` is **required** on main (was optional/implicit before)
- Module require paths use **hyphens** (`nvim-treesitter-textobjects.select`) not dots (`nvim-treesitter.textobjects.select`)

**Step 2:** Verify file parses.

```bash
nvim --headless -c "luafile lua/modules/configs/editor/treesitter.lua" -c "qa" 2>&1
```

Expected: silent (the function returns; doesn't execute).

**Step 3:** Do not commit yet — we'll commit after lazy sync confirms it actually works.

---

### Task 6: Sync lazy and rebuild parsers

**Step 1:** Quit any running Neovim instances.

**Step 2:** Launch nvim. Lazy will detect the branch change for `nvim-treesitter` and re-clone/checkout `main`. The `:TSUpdate` build step will run.

```bash
nvim
```

**Step 3:** Inside nvim, watch for errors. If lazy doesn't auto-switch branches, run:

```vim
:Lazy sync
```

**Step 4:** Verify branch.

```bash
git -C ~/.local/share/nvim/site/lazy/nvim-treesitter rev-parse --abbrev-ref HEAD
git -C ~/.local/share/nvim/site/lazy/nvim-treesitter-textobjects rev-parse --abbrev-ref HEAD
```

Expected: both `main`.

**Step 5:** Verify parsers installing. Inside nvim:

```vim
:checkhealth nvim-treesitter
```

Expected: lists installed parsers under the new install dir, no errors.

**Step 6:** Verify the original crash is gone. Open a file that previously triggered it (any code file) and run a Noice command that opens a split, e.g.:

```vim
:Noice
```

Expected: no `query_predicates.lua` error, no `attempt to call method 'range'`, no E5108.

---

### Task 7: Smoke-test each feature

For each, expected = works without errors.

**Step 1 — Highlighting:** Open `lua/core/init.lua`. Confirm syntax colors render.

**Step 2 — Folding:** In the same file, run `zM` then `zR`. Folds should collapse/expand.

**Step 3 — Indent:** New line inside a function; tab/auto-indent should follow treesitter.

**Step 4 — Textobjects select:** Place cursor in a function, `vif` (select inner function). Should highlight the function body.

**Step 5 — Textobjects move:** `]m` jumps to next class, `[[` to previous function.

**Step 6 — vim-matchup:** Place cursor on `if`/`function`/`do`. `%` should jump to matching `end`. (Regex engine, not TS.)

**Step 7 — treesitter-context:** Scroll inside a long function. Sticky header should appear.

**Step 8 — autotag:** Open an HTML/JSX file, type `<div>`. Closing tag should auto-insert.

**Step 9 — rainbow-delimiters:** Open a Lua file with nested brackets. Brackets should be rainbow-colored.

If any of these fail, **stop** and investigate before committing.

---

### Task 8: Commit the migration

**Step 1:** Stage and commit.

```bash
git -C /home/lars/nvim-config add lua/modules/plugins/editor.lua lua/modules/configs/editor/treesitter.lua lazy-lock.json
git -C /home/lars/nvim-config commit -m "feat(treesitter): migrate nvim-treesitter and textobjects to main branch

- Pin both plugins to branch = main
- Replace legacy configs.setup module config with main-branch APIs
- Switch textobjects requires to nvim-treesitter-textobjects.* namespace
- Declare explicit parser install list via require('nvim-treesitter').install
- Resolves vim-matchup query_predicates crash on Neovim 0.12"
```

---

### Task 9: Clean-up snapshot (optional)

After running for a day or two without regressions:

```bash
git -C /home/lars/nvim-config rm lazy-lock.json.pre-ts-main
git -C /home/lars/nvim-config commit -m "chore: drop pre-migration lockfile snapshot"
```

---

## Rollback procedure

If anything goes wrong and you need to revert:

```bash
cd /home/lars/nvim-config
git checkout main   # or whatever your default branch is
cp lazy-lock.json.pre-ts-main lazy-lock.json
nvim -c ":Lazy restore" -c "qa"
```

Then delete the migration branch: `git branch -D treesitter-main-migration`.
