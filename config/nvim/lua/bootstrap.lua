
local function clone_paq()
  local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
  local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
  if not is_installed then
    vim.fn.system { "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path }
    return true
  end
end

local function packages()
  return {
    "savq/paq-nvim", -- let paq manage itself
    'isobit/vim-caddyfile',
    'RubixDev/mason-update-all',
    'gfanto/fzf-lsp.nvim',
    'nvim-lua/plenary.nvim',
    "lukas-reineke/indent-blankline.nvim",
    "stevearc/dressing.nvim",
    "onsails/lspkind.nvim",
    "norcalli/nvim-colorizer.lua",
    "karb94/neoscroll.nvim",
    "hedyhli/outline.nvim",
    "rcarriga/nvim-notify",
    "folke/noice.nvim",
    "rktjmp/lush.nvim",
    "olimorris/onedarkpro.nvim",
    'tpope/vim-sensible',
    'folke/which-key.nvim',
    "numToStr/FTerm.nvim",
    "vim-crystal/vim-crystal",
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",

    -- Terminal-related:
    'kassio/neoterm',

    -- Common:
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    -- 'neovim/nvim-lspconfig',

    -- Mason.nvim
    'williamboman/mason.nvim',
    -- 'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    "smjonas/inc-rename.nvim",

    -- mini statusline
    'lewis6991/gitsigns.nvim',
    'nvim-tree/nvim-web-devicons',
    { 'echasnovski/mini.nvim', branch = 'main' },

    'duane9/nvim-rg',

    -- telescope
    'burntsushi/ripgrep',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-telescope/telescope.nvim',

    -- tree-sitter
    { 'nvim-treesitter/nvim-treesitter', build = function() vim.cmd 'TSUpdate' end },

    -- Neo-tree
    { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x", },

    -- Nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'dcampos/nvim-snippy',
    'dcampos/cmp-snippy'
  }
end -- function

local function headless_paq()
  local first_install = clone_paq()
  vim.cmd.packadd("paq-nvim")
  local paq = require("paq")
  if first_install then
    vim.notify("Installing plugins... If prompted, hit Enter to continue.")
  end

  -- Set to exit nvim after installing plugins
  vim.cmd("autocmd User PaqDoneSync quit")
  -- Read and install packages
  paq(packages())
  paq:sync()
end -- function

local function headless_mason()
  require("mason").setup()
  vim.cmd("MasonUpdate")
  local mti = require('mason-tool-installer')
  mti.setup {
    auto_update = true,
    run_on_start = false,
    start_delay = 0,
  }
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonToolsUpdateCompleted',
    callback = function(e)
      vim.schedule(function()
        print(vim.inspect(e.data)) -- print the table that lists the programs that were installed
      vim.cmd("qall")
      end)
    end,
  })
  mti.check_install(true)
end -- function


local function headless_treesitter()
  vim.cmd("TSUpdateSync")
end -- function

local function paq_packages()
  return require('paq')(packages())
end

return {
  headless_paq = headless_paq,
  headless_mason = headless_mason,
  headless_treesitter = headless_treesitter,
  treesitters = treesitters,
  paq_packages = paq_packages
}
