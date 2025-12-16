return {
  -- 1. Core Dependencies & Package Manager
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",

  -- 2. Theme (GitHub)
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          -- 编译主题以加快加载速度
          compile_path = vim.fn.stdpath("cache") .. "/github-theme",
          compile_file_suffix = "_compiled",
          hide_end_of_buffer = true, -- 隐藏缓冲区结束符 (~)
          hide_nc_statusline = true, -- 隐藏非活动窗口的状态栏
          transparent = false,       -- 禁用透明背景
        },
      })
      -- 默认使用 GitHub Dark Dimmed (最接近网页版暗色)
      -- 如果需要亮色，可以改为 github_light
      vim.cmd("colorscheme github_dark_dimmed")
    end,
  },

  -- 3. UI Enhancements (Statusline & Keymaps)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "auto" }, -- auto 会自动适配当前 colorscheme
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  -- 4. File Navigation (Telescope & Neo-tree & Flash)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("config.telescope") end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- 5. Editing Efficiency (Mini.nvim Bundle)
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.surround").setup() -- Fast surround (sa/sd/sr)
      require("mini.comment").setup()  -- Fast comment (gc)
      require("mini.pairs").setup()    -- Auto pairs
      require("mini.ai").setup()       -- Enhanced text objects (va)
    end,
  },

  -- 6. Syntax Highlighting & Git
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function() require("config.treesitter") end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- 7. LSP & Completion (Lightweight)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function() require("config.lsp") end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function() require("config.cmp") end,
  },
}
