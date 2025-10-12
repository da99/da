
local set        = vim.opt
local g          = vim.g
local fn         = vim.fn
local api        = vim.api
local set_keymap = api.nvim_set_keymap
local cmd        = vim.cmd
local env        = vim.env
local is_256     = env.TERM == "xterm-256color"

g.sql_type_default = 'pgsql'
g.indentLine_char      = '┊'
g.indentLine_setColors = 0
g.mapleader            = ' '
g.neoterm_autoscroll   = 1
g.neoterm_shell = 'zsh'
vim.opt.report = 1000 -- https://www.reddit.com/r/vim/comments/nk3xss/how_to_disable_messages_from_ypu/

if is_256 then

  set.termguicolors = true
  g.rg_highlight                   = true -- Highlight :Rg results
  g.rg_command                     = "rg --vimgrep --hidden -g '!.git/'"

  -- cmd([[
  --   set cursorlineopt=number
  --   set cursorline
  --   set background=light
  --   hi Pmenu  ctermbg=233  ctermfg=137    guibg=#D5D5D5  guifg=#171717  cterm=none      gui=NONE
  --   hi PmenuSel guifg=#E5C078 guibg=#000000
  --   hi PmenuThumb guibg=#C3A56A
  --   hi NormalFloat guibg=#000000
  --   hi Conceal guifg=#1E1E1E
  --   " hi PmenuThumb      ctermbg=235  ctermfg=137    guibg=NONE     guifg=#171717  cterm=none      gui=none
  --   highlight Comment cterm=italic gui=italic
  --   " set guicursor+=n-v-c-sm:blinkon1
  -- ]])

  if (fn.filereadable('/tmp/light.editor') == 1) then
    cmd([[
      packadd vim-github-colorscheme
      set background=light
      colorscheme github
      set background=light
      hi ActiveWindow guibg=#DBDBDB
      hi InactiveWinAow guibg=#EAEAEA
    ]])
  else
      -- " colorscheme onedark
      -- " 
    vim.cmd([[
      set background=dark
      let g:oceanic_next_terminal_bold = 1
      let g:oceanic_next_terminal_italic = 1
    ]])
    require('onedark').setup {
      style = 'darker'
    }
    require('onedark').load()
  end
  -- cmd([[
  --   hi Search guifg=#FFFFFF
  -- ]])
end

set.signcolumn  = "number"
set.scrolloff   = 3    -- Start scrolling when we're 2 lines away from margins
set.autoread    = true -- Reload files changed outside vim:
set.smartindent = true
set.showtabline = 1 -- Only when 2 or more tab pages
set.wrap        = false
set.expandtab   = true
set.list        = true -- https://www.reddit.com/r/neovim/comments/chlmfk/highlight_trailing_whitespaces_in_neovim/
set.cmdheight   = 1
set.shiftwidth  = 2
set.ignorecase  = true

-- " Suppress the annoying 'match x of y', 'The only match' and 'Pattern not
-- " found' messages
set.shortmess:append('c')

-- from: https://github.com/skwp/dotfiles/blob/master/vimrc
set.listchars = { tab = '⇒␣', trail = '·', nbsp = '␠', extends = '⮚', precedes = '⮘' }
set.list = true
-- eol:¬,
-- =============================================================================


local vim_temp_dir = "/progs/tmp/nvim"
set.swapfile  = false
set.backup    = false
set.directory = vim_temp_dir .. "/.swap"
set.undodir   = vim_temp_dir .. "/.undo"
set.backupdir = vim_temp_dir .. "/.backup"

set.number     = true
set.updatetime = 1000
set.timeoutlen = 500
set.shell      = "sh"

-- ============================================================================
-- Key maps:
-- ============================================================================
-- autocmd FileType help nnoremap <buffer>' <CMD>cclose<CR>
set_keymap('n', '<SPACE>', '<NOP>', {noremap = true})
-- ============================================================================
-- ======================= Dangerous ==========================================
-- ============================================================================
set_keymap('n', '<Leader>die', '<CMD>lua local x = vim.fn.expand("%:p"); vim.fn.delete(x); vim.notify("Deleted: " .. x, "warn"); vim.cmd("bdelete!")<CR>', {noremap = true})
-- ============================================================================

-- =============================================================================
-- Visual:
-- https://vi.stackexchange.com/questions/8433/how-do-you-indent-without-leaving-visual-mode-and-losing-your-current-select
-- =============================================================================
set_keymap('v', '>', '>gv', {noremap = true, silent = true})  -- # https://vi.stackexchange.com/questions/8433/how-do-you-indent-without-leaving-visual-mode-and-losing-your-current-select
set_keymap('v', '<', '<gv', {noremap = true, silent = true})
set_keymap('v', '<C-Space>', '<ESC>', {})
set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
-- =============================================================================
--
--

-- =============================================================================
-- Terminal mode:
-- =============================================================================
-- nnoremap <Leader>term <C-w><C-s>6<C-w>+<C-w><down>:<C-u>term<CR>
-- tnoremap <C-v> <C-\><C-n>"+pi
set_keymap('t', '<C-t><C-t>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', {})
set_keymap('t', '<C-w>', '<C-\\><C-n><C-w>', {noremap=true, silent=true})
-- =============================================================================

-- =============================================================================
-- Insert mode:
-- =============================================================================
set_keymap('i', '<C-Space>', '<ESC>', {})
set_keymap('i', '<C-v>', '<ESC>"+pa', {})
set_keymap('i', '<C-s>', '<ESC>:update<CR>a', {})
set_keymap('i', '<M-x>', '<CMD>lua vim.lsp.buf.signature_help()<CR>', {noremap=true})
set_keymap('i', '<M-c>', '<CMD>lua MiniCompletion.complete_twostage()<CR>', {noremap=true})
-- =============================================================================

-- =============================================================================
-- Normal mode:
-- =============================================================================
set_keymap('n', '<C-z>', 'u', {silent = true}) -- " http://vim.wikia.com/wiki/Saving_a_file
set_keymap('n', 'ga', '<Plug>(EasyAlign)', {noremap = true})

-- =============================================================================
-- Web Development:
-- =============================================================================
set_keymap('n', '<Leader>ww', ':! __ dev build file %<CR>', {noremap=false, silent=true})

-- =============================================================================
-- Comments:
-- =============================================================================
set_keymap('n', '<Leader>div', 'A<CR>=<ESC>v"9y76pgcco<ESC>gcc', {noremap=false, silent=true})
set_keymap('n', '<Leader>ddiv', '<Leader>div<UP>V"9y<DOWN>p<UP>i', {noremap=false, silent=true})

set_keymap('n', '<Leader>hy', ':! xdg-open https://www.google.com/search?q=<C-r><C-w>', {noremap=true, silent=false})

-- set_keymap('n', '<Leader>xx', '<CMD>TroubleToggle document_diagnostics<CR>', {noremap=true, silent=true})
-- " Turn off the highlighted items searched for:
-- "   <C-l> is nvim default for :
-- "     n  <C-L>       * <Cmd>nohlsearch|diffupdate|normal! <C-L><CR>
-- " Clear highlight search and do a regular search.
set_keymap('n', '<ESC>', '<CMD>nohlsearch <BAR> diffupdate <BAR> normal! <C-L><CR>', {});

set_keymap('n', '<C-s>', ':update<CR>', {})

set_keymap('n', '<C-t><C-t>', ':lua require("FTerm").toggle()<CR>', {})

-- =============================================================================
-- Columns:
-- =============================================================================
set_keymap('n', '<Leader>col', '<CMD>set cursorcolumn!<CR>', {noremap = true, silent = true})
set_keymap('n', '<Leader>=', '10l', {noremap = true})
set_keymap('n', '<Leader>-', '10h', {noremap = true})
-- =============================================================================

-- =============================================================================
-- Tabs:
-- =============================================================================
set_keymap('n', '<Leader><TAB>', '<CMD>tabnext<CR>', {noremap=true, silent=true})
-- =============================================================================

set_keymap('n', '<Leader>ol', '<CMD>:call ToggleLocationList()<CR>', {})
set_keymap('n', '<Leader>op', '<CMD>:call ToggleQuickfixList()<CR>', {})

set_keymap('n', '<Leader>ee', '<CMD>Neotree filesystem reveal left<CR>', {})

set_keymap('n', '<Leader>bb', '<CMD>bnext<CR>', {})
set_keymap('n', '<Leader>bd', ':bdelete<CR>', {})
set_keymap('n', '<Leader>bv', '<CMD>bprevious<CR>', {})
-- set_keymap('n', '<Leader>a', ':Startify<CR>', {})
set_keymap('n', '<Leader>000', ':qa<CR>', {})
set_keymap('n', '<Leader>l', 'o<ESC>', {})
set_keymap('n', '<Leader>L', 'O<ESC>', {})

-- " ===============================================
-- " LSP:
-- " ===============================================
set_keymap('n', '<Leader>qa', '<CMD>lua vim.diagnostic.open_float()<CR>', { noremap=true, silent=true })
set_keymap('n', '<Leader>qe', '<CMD>lua vim.diagnostic.goto_next()<CR>', { noremap=true, silent=true })
set_keymap('n', '<Leader>qq', '<CMD>lua vim.lsp.buf.hover()<CR>', {})
set_keymap('n', '<Leader>qw', '<CMD>lua vim.lsp.buf.definition()<CR>', {noremap = true})
set_keymap('n', '<Leader>qi', '<CMD>checkhealth vim.lsp<CR>', {noremap = true})
-- set_keymap('n', '<Leader>qr', '<CMD>lua vim.lsp.buf.rename()<CR>', {noremap = true})
set_keymap('n', '<Leader>qr', ':IncRename ', {noremap = true})
set_keymap('n', '<Leader>qo', '<CMD>Outline<CR>', {noremap = true, desc = "Toggle outline."})
set_keymap('n', '<Leader>fr', '<CMD>References<CR>', {noremap = true, desc = "Find references."})
set_keymap('n', '<Leader>ff', '<CMD>DocumentSymbols<CR>', {noremap = true, desc = "Find document symbols."})
-- " ===============================================

set_keymap('n', '<Leader>rg', '<CMD>:Rg<CR>', {})

set_keymap('n', '++', '<CMD>:cnext<CR>', {})
set_keymap('n', '__', '<CMD>:cprevious<CR>', {})

-- " ===============================================
set_keymap('v', '<Leader>1', 'gAs%s+<CR>fn == 1<CR>', {})
set_keymap('v', '<Leader>2', 'gAs%s+<CR>fn == 2<CR>', {})
set_keymap('v', '<Leader>3', 'gAs%s+<CR>fn == 2 or n == 3<CR>', {})



-- " ===============================================
-- " Dev:
-- " ===============================================
function tmp_run_edit(i)
  return vim.cmd.edit(tmp_run_filename(i))
end

function tmp_run_filename(i)
  local raw_filename = vim.fn.system('da.sh filename tmp/run ' .. i )
  return vim.fn.substitute(raw_filename, '\\W\\+$', '' , '' )
end

-- function bootstrap()
--   local bs = require('bootstrap')
--   bs.paq_packages()
--   return require('paq')
-- end -- function
local bootstrap = require('bootstrap')
bootstrap.paq_packages()

for i = 1, 3 do
  set_keymap('n', '<Leader>' .. i .. i, ":Topen<CR>:T da.sh run tmp/run " .. i .. "<CR>", {noremap=true})
  set_keymap( 'n', '<Leader>' .. i .. 'e', ":lua tmp_run_edit(" .. i .. ")<CR>", {noremap=true})
end
set_keymap('n', '<Leader>pp', ':lua print(vim.inspect())<Left><Left>', {noremap=true})

-- ===============================================
-- Buffers:
-- ===============================================
-- for i = 1, 9 do
--  set_keymap('n', '<Leader>b' .. i, '<CMD>buffer ' .. i .. '<CR>', {noremap = true, silent = true})
-- end

-- ===============================================
-- Fuzzy finders:
-- ===============================================
set_keymap('n', '<Leader>tr', "<CMD>Telescope oldfiles<CR>", {noremap = true, silent = true})
set_keymap('n', '<Leader>ty', "<CMD>Telescope find_files<CR>", {noremap = true, silent = true})
-- set_keymap('n', '<Leader>fg', "<CMD>Telescope buffers<CR>", {noremap = true, silent = true})
set_keymap('n', '<Leader>tf', "<CMD>Telescope current_buffer_fuzzy_find<CR>", {noremap = true, silent = true})
-- set_keymap('n', '<Leader>fr', "<CMD>Telescope command_history<CR>", {noremap = true, silent = true})
set_keymap('n', '<Leader>t ', "<CMD>Telescope<CR>", {noremap = true, silent = true})
-- set_keymap('n', '<Leader>ss', "<Plug>Lightspeed_s", {noremap = false, silent = false})
-- set_keymap('n', '<Leader>sa', "<Plug>Lightspeed_S", {noremap = false, silent = false})
-- ===============================================

-- ===============================================
-- Nvim-snippy:
-- ===============================================
-- set_keymap('i', '<M-s>', "snippy#can_expand_or_advance() ? '<Plug>(snippy-expand-or-advance)' : ''", {noremap=false, expr = true})
-- imap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'
-- smap <expr> <Tab> snippy#can_jump(1) ? '<Plug>(snippy-next)' : '<Tab>'
-- smap <expr> <S-Tab> snippy#can_jump(-1) ? '<Plug>(snippy-previous)' : '<S-Tab>'
-- xmap <Tab> <Plug>(snippy-cut-text)
-- ===============================================

-- cmd([[
--  inoremap <silent><expr> <Tab> pumvisible() ? "\<C-n>" : "\<TAB>"
--  inoremap <silent><expr> <CR>  pumvisible() ? "\<C-y>" : v:lua.MPairs.autopairs_cr()
--  cnoremap         <expr> <CR>  pumvisible() ? "<C-y> " : "<CR>"
-- ]])

-- =============================================================================

-- =============================================================================
-- WhichKey: https://github.com/folke/which-key.nvim
-- =============================================================================
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    require("which-key").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }


-- =============================================================================
-- Disable builtin plugins I don't need for now:
-- From: https://dev.to/voyeg3r/my-ever-growing-neovim-init-lua-h0p
-- =============================================================================
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    g["loaded_" .. plugin] = 1
end
-- =============================================================================

-- =============================================================================
-- cmd([[
--   augroup my_defaults
--     autocmd!
--     autocmd TermOpen * IndentLinesDisable | startinsert
--     autocmd TermClose * if !v:event.status | exe 'bdelete! '..expand('<abuf>') | endif
--     autocmd BufNewFile,BufRead *.njk, set ft=jinja
--     autocmd BufRead,BufNewFile *.xdefaults setfiletype xdefaults
--   augroup END
-- ]])
-- =============================================================================

-- ===============================================
-- Colorschemes:
-- ===============================================
-- use 'endel/vim-github-colorscheme'
-- use 'EdenEast/nightfox.nvim'
-- use 'folke/tokyonight.nvim'

if is_256 then
    -- require('nightfox').setup({
    --   options = { dim_inactive = true }
    -- })
    -- cmd([[
    --   set background=dark
    --   colorscheme toast
    --   hi Normal guibg=#10161B
    -- ]])
    -- cmd([[
    --   set background=dark
    --   colorscheme OceanicNext
    --   hi Normal guibg=#0F161A
    -- ]])
    -- cmd([[
    --   set background=dark
    --
    --   augroup MyColors
    --     autocmd!
    --     autocmd ColorScheme * hi String guifg=#7CC745 | hi NormalFloat guibg=#202033 | hi Pmenu guibg=#202033 | hi PmenuSel guifg=#ffcb65 guibg=#161630 | hi PmenuThumb guibg=#202033
    --   augroup END
    --
    --   colorscheme aurora
    -- ]])
    -- cmd([[
      -- " colorscheme nimda
      -- " hi Normal guibg=#E3E3E3
    -- ]])
    --   packadd jellybeans.vim
    --   set background=dark
    --   colorscheme jellybeans
    --   set background=dark
    --   hi InactiveWindow guibg=#192330
    -- ]])

  -- cmd([[
  --   packadd onedark.vim
  --   colorscheme onedark
  --   highlight Normal guibg=#1A1C20
  --   ]])
  -- cmd([[
  --   packadd vim-one
  --   colorscheme one
  --   highlight Normal guibg=#E8E8E8
  -- ]])
end -- if is_256


-- =============================================================================
-- Mini.nvim:
-- =============================================================================
require('mini.statusline').setup()
require('mini.tabline').setup()
require('mini.trailspace').setup()
require('mini.pairs').setup()
require('mini.comment').setup()
require('mini.bracketed').setup()
require('mini.surround').setup({})
require('mini.align').setup()

require('mini.completion').setup({
  mappings = {
    force_twostep = '', -- Force two-step completion
    force_fallback = '', -- Force fallback completion
  }
})
cmd(' autocmd! MiniCompletion InsertCharPre * ')
-- =============================================================================

cmd(' highlight MiniStatuslineFilename                guifg=#8EBD6B')
cmd(' highlight MiniTablineCurrent guifg=#8EBD6B               ')
cmd(' highlight MiniTablineHidden                guifg=#545452')
-- cmd(' highlight MiniTablineVisible                guifg=#545452')
-- cmd(' highlight MiniTablineModifiedCurrent guibg=#e8ad00 guifg=#000000 ')
-- cmd(' highlight MiniTablineModifiedVisible guibg=#7f5e36 guifg=#000000 ')
-- cmd(' highlight MiniTablineModifiedHidden guibg=#7f5e36 guifg=#000000 ')

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
    note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
-- =============================================================================


-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
local telescope = require('telescope')
telescope.setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        ["<C-h>"] = "which_key"
      },
      n = {
        ["<C-h>"] = "which_key"
      },
    },
    initial_mode = "insert"
  },
}
telescope.load_extension('fzf')

require('gitsigns').setup()
-- require("symbols-outline").setup()

-- =============================================================================
-- Mason.nvim
-- =============================================================================
-- require('mason').setup()
-- require('mason-update-all').setup()

require("inc_rename").setup()

-- =============================================================================
-- NVIM-CMP
-- =============================================================================
local lspkind = require'lspkind'
lspkind.init({ mode = 'symbol_text' })

local cmp = require'cmp'
local function has_words_before()
  local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end
cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('snippy').expand_snippet(args.body) -- For `snippy` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-c>'] = cmp.mapping.complete(),
    -- Disable preselect: https://www.reddit.com/r/neovim/comments/119tqnm/comment/j9pyndx/
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-e>'] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
    ['<Tab>'] = cmp.mapping(function(fallback)
      local snippy = require('snippy')
      if cmp.visible() then
        cmp.select_next_item()
      elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif snippy.can_jump(-1) then
        snippy.previous()
      else
        fallback()
      end
    end, { "i", "s" }),

  }),
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    })
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'buffer', priority = 500 },
    { name = 'path', priority = 250 },
    { name = 'snippy', priority = 150 },
  })
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
  { { name = 'path' } },
  { { name = 'cmdline' } }
  )
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config('bashls', {
  -- capabilities = capabilities,
  cmd = {'bash-language-server', 'start'},
  settings = {
    bashIde = {
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.bash)',
    },
  },
  filetypes = { 'bash', 'sh' },
  root_markers = { '.git' },
})
vim.lsp.enable('bashls')

-- =============================================================================
vim.lsp.config('luals', {
  -- capabilities = capabilities,
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  root_markers = {'.git'},
})

vim.lsp.enable('luals')

-- =============================================================================
vim.lsp.config('jsonls', {
  -- capabilities = capabilities,
  cmd = {"vscode-json-language-server", "--stdio"},
  filetypes = {'json'},
  root_markers = {'.git'},
})
vim.lsp.enable('jsonls')

-- =============================================================================
vim.lsp.config('cssls', {
  -- capabilities = capabilities,
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  init_options = { provideFormatter = true }, -- needed to enable formatting capabilities
  root_markers = { 'package.json', '.git' },
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
})
vim.lsp.enable('cssls')

-- =============================================================================
vim.lsp.config('html-ls', {
  -- capabilities = capabilities,
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html', 'templ' },
  root_markers = { 'package.json', '.git' },
  settings = {},
  init_options = {
    provideFormatter = true,
    embeddedLanguages = { css = true, javascript = true },
    configurationSection = { 'html', 'css', 'javascript' },
  },
})
vim.lsp.enable('html-ls')

-- =============================================================================
vim.lsp.config('tsserver', {
  -- capabilities = capabilities,
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'typescript' },
  root_markers = { 'package.json', '.git', 'tsconfig.json' },
})
vim.lsp.enable('tsserver')
-- =============================================================================
vim.lsp.config('css-ls', {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  init_options = { provideFormatter = true }, -- needed to enable formatting capabilities
  root_markers = { 'package.json', '.git' },
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
})
vim.lsp.enable('css-ls')

-- =============================================================================
vim.lsp.config('emmet-language-server', {
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = {
    'astro',
    'css',
    'eruby',
    'html',
    'htmlangular',
    'htmldjango',
    'javascriptreact',
    'less',
    'pug',
    'sass',
    'scss',
    'svelte',
    'templ',
    'typescriptreact',
    'vue',
  },
  root_markers = { '.git' },
})
vim.lsp.enable('emmet-language-server')

-- lspconfig.jsonls.setup{ cmd = {  } } -- https://github.com/pwntester/nvim-lsp
-- lspconfig.sumneko_lua.setup({ })
-- lspconfig.bashls.setup{
--   capabilities = capabilities,
-- }


vim.lsp.config('solargraph', {
  -- capabilities = capabilities,
  cmd = { 'solargraph', 'stdio' },
  settings = {
    solargraph = {
      diagnostics = true,
    },
  },
  init_options = { formatting = true },
  filetypes = { 'ruby' },
  root_markers = { 'Gemfile', '.git' },
})
vim.lsp.enable('solargraph')

-- =============================================================================
vim.lsp.config('gopls', {
  capabilities = capabilities,
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { '.git', 'go.mod' },
})
vim.lsp.enable('gopls')

-- =============================================================================
vim.lsp.config('sql-language-server', {
  capabilities = capabilities,
  cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
  filetypes = { 'sql' },
  root_markers = { '.git' },
})
vim.lsp.enable('sql-language-server')



-- =============================================================================
local ra_on_attach = function(client)
    require'completion'.on_attach(client)
end
-- lspconfig.rust_analyzer.setup{
--     settings = {
--       ["rust-analyzer"] = {
--             imports = {
--                 granularity = {
--                     group = "module",
--                 },
--                 prefix = "self",
--             },
--             cargo = {
--                 buildScripts = {
--                     enable = true,
--                 },
--             },
--             procMacro = {
--                 enable = true
--             },
--           }
--     }
-- }

-- =============================================================================
-- From: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#denols
-- NOTE: To appropriately highlight codefences returned from denols:
vim.g.markdown_fenced_languages = { "ts=typescript" }
-- lspconfig.denols.setup{
--   capabilities = capabilities,
--   root_dir = util.root_pattern('deno.json', 'deno.jsonc', '.git', '.'),
-- }
-- lspconfig.ts_ls.setup{
-- --   capabilities = capabilities,
-- --   root_dir = util.root_pattern('tsconfig.json', '.git', '.'),
--   settings = {
--     client = {
--       enable = false
--     }
--   }
-- }

-- lspconfig.html.setup{
--   filetypes = { "html" },
--   capabilities = capabilities,
-- }

-- Emmet HTML completion:
-- From: https://github.com/aca/emmet-ls

-- lspconfig.emmet_ls.setup({
--     -- on_attach = on_attach,
--     capabilities = capabilities,
--     filetypes = { "eruby", "html", "javascriptreact", "svelte", "pug", "typescriptreact", "vue" },
--     init_options = {
--       html = {
--         options = {
--           -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
--           ["bem.enabled"] = true,
--         },
--       },
--     }
-- })

-- require "lspconfig".efm.setup {
--     init_options = {documentFormatting = true},
--     settings = { rootMarkers = {".git/"}, },
--     filetypes = {'sh'}
-- }
-- local lsp_util = require('lspconfig.util')
-- # From: https://github.com/samhh/dotfiles/blob/99e67298fbcb61d7398ad1850f3c2df31d90bd0d/home/.config/nvim/plugin/lsp.lua#L120
-- lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(
--   lsp.diagnostic.on_publish_diagnostics,
--   {
--     virtual_text = false,
--     signs = true,
--     update_in_insert = false,
--     underline = true,
--     border = 'rounded'
--   }
--   )
-- require "lsp_signature".setup({
--   bind = true, -- This is mandatory, otherwise border config won't get registered.
--   handler_opts = {
--     border = "rounded"
--   }
-- })
-- =============================================================================

-- =============================================================================


vim.notify = require("notify")
vim.notify.setup{
  render = "wrapped-compact"
}
-- require("noice").setup()

-- =============================================================================
-- Treesitter:
-- =============================================================================
require'nvim-treesitter.configs'.setup {
  sync_install = false,
  auto_install = true,
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1500
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  }
}
-- =============================================================================
-- Colorizer:
-- =============================================================================
require('colorizer').setup({
  'typescript',
  'vim',
  'lua',
  'jinja',
  'less',
  'html',
  'sh',
  'zsh',
  'ruby',
  css = {names = true}
}, {names = false})

require('neoscroll').setup()

require("outline").setup {
   symbol_folding = {
    -- Depth past which nodes will be folded by default
    autofold_depth = 0,
  },
}

require("ibl").setup()




local snippy = require('snippy')
snippy.setup({})



require("neo-tree").setup({
  filesystem = {
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
    }
  }
})
-- if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.v.argv[3]) ~= 0  then
-- end

vim.filetype.add({
  extension = {
    ['.pgsql'] = 'pgsql',
  },
})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = { "*.pgsql" }, -- Replace with the actual path to your file
  callback = function()
    vim.bo.filetype = "pgsql" -- Set the filetype to 'log'

    -- From: https://github.com/LazyVim/LazyVim/discussions/654#discussioncomment-10978917
    vim.bo.commentstring = "-- %s" -- Set the filetype to 'log'
  end,
})

