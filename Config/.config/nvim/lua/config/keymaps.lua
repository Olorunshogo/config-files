-- Loaded on VeryLazy. LazyVim defaults live in
-- ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/keymaps.lua
-- Press <leader>sk to search every keymap, or just <leader> and wait.

local map = vim.keymap.set

-- === Scrolling
-- Scroll 35% of the window instead of 50% and keep the cursor centered, so
-- you never lose your place
local scroll_percentage = 0.35
map("n", "<C-d>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "jzz")
end, { desc = "Scroll down (centered)" })
map("n", "<C-u>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "kzz")
end, { desc = "Scroll up (centered)" })

-- Keep search matches centered
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- === Editing
-- Paste over a selection without losing what you yanked
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })

-- === Windows
-- Flip two splits between side-by-side and stacked. Vim only has "move this
-- window to an edge" (<C-w>HJKL), so this picks the right one for you.
map("n", "<leader>wt", function()
  local layout = vim.fn.winlayout()
  if layout[1] == "leaf" or #layout[2] ~= 2 then
    vim.notify("Split toggle works with exactly two splits", vim.log.levels.WARN)
    return
  end
  vim.cmd(layout[1] == "row" and "wincmd K" or "wincmd H")
end, { desc = "Toggle split vertical/horizontal" })

-- === Git
if vim.fn.executable("lazygit") == 1 then
  map("n", "<M-g>", function()
    Snacks.lazygit({ cwd = LazyVim.root.git() })
  end, { desc = "Lazygit (root dir)" })
end
