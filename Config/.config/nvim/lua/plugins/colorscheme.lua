-- Switch at any time with <leader>uC; set the default below.
return {
  { "eldritch-theme/eldritch.nvim", lazy = true, name = "eldritch", opts = {} },
  { "catppuccin/nvim", lazy = true, name = "catppuccin" },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "eldritch" },
  },
}
