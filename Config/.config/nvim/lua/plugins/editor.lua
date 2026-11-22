-- Overrides for plugins LazyVim already ships, plus small editor additions.
return {
  -- === Motion
  {
    "folke/flash.nvim",
    opts = {
      search = { mode = "search" },
      -- Keep f/F/t/T as plain Vim so the muscle memory you build transfers to any Vim
      modes = { char = { enabled = false } },
    },
  },

  -- === Learning aid
  -- Blocks repeated hjkl/arrow spam and suggests a better motion.
  -- Turn off for a session with :Hardtime toggle
  {
    "m4xshen/hardtime.nvim",
    event = "BufEnter",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      max_count = 12,
      restricted_keys = { ["gj"] = false, ["gk"] = false },
      disabled_filetypes = { "lazy", "mason", "neo-tree", "minifiles", "snacks_dashboard", "trouble" },
    },
  },

  -- === Multiple cursors (<C-n> on a word, then <C-n> again for the next match)
  { "mg979/vim-visual-multi", event = "VeryLazy" },

  -- === Keep the cursor line centered while moving (<leader>uS to toggle)
  {
    "arnamak/stay-centered.nvim",
    event = "VeryLazy",
    opts = { skip_filetypes = { "snacks_dashboard" } },
    keys = {
      {
        "<leader>uS",
        function()
          require("stay-centered").toggle()
        end,
        desc = "Toggle stay-centered",
      },
    },
  },

  -- === Search and replace across the project, prefilled with this file's extension
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>sr",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          require("grug-far").open({
            transient = true,
            prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },

  -- === Which-key
  -- Longer delay so the popup only shows when you actually pause to think
  { "folke/which-key.nvim", opts = { delay = 600 } },
}
