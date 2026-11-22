return {
  -- Magit-style git UI, works without lazygit installed
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "folke/snacks.nvim",
    },
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
    opts = {},
  },
}
