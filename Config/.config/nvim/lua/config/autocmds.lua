-- Loaded on VeryLazy. LazyVim defaults live in
-- ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/autocmds.lua

-- === Autosave
-- Saves when focus moves away: another app or terminal tab, another file, another
-- split, or quitting. Set vim.g.autosave = false (here or with :let) to turn it off.
vim.g.autosave = true

local function autosave(buf)
  if not vim.g.autosave or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local bo = vim.bo[buf]
  -- Only real files: skips scratch/unnamed buffers and plugin windows (tree, lazygit, Trouble)
  if bo.modified and bo.buftype == "" and bo.modifiable and not bo.readonly and vim.api.nvim_buf_get_name(buf) ~= "" then
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent! lockmarks update")
    end)
  end
end

local autosave_group = vim.api.nvim_create_augroup("user_autosave", { clear = true })

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  group = autosave_group,
  callback = function(ev)
    autosave(ev.buf)
  end,
})

vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
  group = autosave_group,
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      autosave(buf)
    end
  end,
})

-- === Indentation
-- Some ftplugins still override shiftwidth; re-assert 2 spaces after they run.
-- Go is excluded because gofmt mandates tabs (they display 2 wide via tabstop).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_two_space_indent", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "go" or vim.bo[ev.buf].filetype == "make" then
      vim.bo[ev.buf].expandtab = false
      return
    end
    vim.bo[ev.buf].tabstop = 2
    vim.bo[ev.buf].softtabstop = 2
    vim.bo[ev.buf].shiftwidth = 2
    vim.bo[ev.buf].expandtab = true
  end,
})
