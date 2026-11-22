return {
  -- === Messages and command line
  {
    "folke/noice.nvim",
    opts = {
      presets = { bottom_search = false, lsp_doc_border = true },
      views = {
        cmdline_popup = { position = { row = "40%", col = "50%" } },
      },
    },
  },

  -- === Ruler at column 80 (matches textwidth)
  {
    "lukas-reineke/virt-column.nvim",
    event = "VeryLazy",
    opts = { char = "│", virtcolumn = "80" },
  },

  -- === Sticky function/class header at the top while scrolling
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = { mode = "cursor", max_lines = 3 },
  },

  -- === Diagnostics list
  {
    "folke/trouble.nvim",
    opts = {
      modes = { lsp = { win = { position = "right" } } },
      keys = { ["<esc>"] = "close" },
    },
  },
}
