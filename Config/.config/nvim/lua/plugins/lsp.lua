return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Inlay hints get noisy in TS/Rust; toggle per buffer with <leader>uh
      inlay_hints = { enabled = false },
      diagnostics = { float = { border = "rounded" } },
    },
  },

  -- v9+ needs Neovim 0.12; drop this pin after upgrading Neovim
  { "mrcjkb/rustaceanvim", version = "^8" },

  -- Extra tools Mason should install. rust-analyzer is deliberately absent:
  -- the rustup-managed one in ~/.cargo/bin is used instead.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "bash-language-server",
        "shellcheck",
        "shfmt",
        "lua-language-server",
        "stylua",
      })
    end,
  },

  -- Treesitter parsers for the rest of your stack
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "css",
        "html",
        "scss",
        "sql",
        "graphql",
      })
    end,
  },

  -- shfmt follows the 2-space convention
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
      },
    },
  },
}
