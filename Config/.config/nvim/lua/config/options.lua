-- Loaded before plugins. LazyVim defaults live in
-- ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/config/options.lua
-- Only settings that differ from those defaults go here.

-- === Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- === Indentation (2 spaces everywhere)
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.breakindent = true

-- Built-in ftplugins for these languages force 4-space indent unless disabled
vim.g.rust_recommended_style = 0
vim.g.python_recommended_style = 0
vim.g.markdown_recommended_style = 0

-- === UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.wrap = true
vim.opt.textwidth = 80
vim.opt.scrolloff = 8
-- Show markdown/json syntax as written instead of hiding it, easier while learning
vim.opt.conceallevel = 0

-- === Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- === Files
-- :q, :qa and :e save first instead of refusing; :q! still discards
vim.opt.autowriteall = true
vim.opt.wildignore = { "*.o", "*.a", "__pycache__" }
vim.opt.spelllang = { "en" }

-- === LSP
-- rust-analyzer comes from ~/.cargo/bin, not Mason
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
