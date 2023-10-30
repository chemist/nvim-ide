-- Minimal nvim config with lazy
-- Assumes a directory in $NVIM_DATA_MINIMAL
-- Start with
--
-- export NVIM_DATA_MINIMAL=$(mktemp -d)
-- export NVIM_APP_NAME="nvim-ht-minimal"
-- nvim -u minimal.lua
--
-- Then exit out of neovim and start again.
-- Ignore default config
local config_path = vim.fn.stdpath('config')
vim.opt.rtp:remove(config_path)
-- Ignore default plugins
local data_path = vim.fn.stdpath('data')
local pack_path = data_path .. '/site'
vim.opt.packpath:remove(pack_path)
-- bootstrap lazy.nvim
data_path = assert(os.getenv('NVIM_DATA_MINIMAL'), '$NVIM_DATA_MINIMAL environment variable not set!')
local lazypath = data_path .. '/lazy/lazy.nvim'
local uv = vim.uv
  ---@diagnostic disable-next-line: deprecated
  or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'git@github.com:folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
local lazy = require('lazy')
lazy.setup({
  {
    'mrcjkb/haskell-tools.nvim',
    branch = '2.x.x',
    init = function()
      -- Configure haskell-tools.nvim here
      vim.g.haskell_tools = {
        tools = {
          repl = {
            handler = 'toggleterm',
            auto_focus = true,
          }
        }
      }
    end,
    dependencies = {
      -- 'nvim-lua/plenary.nvim',
      -- Uncomment or add any optional dependencies needed to reproduce the issue
      -- 'nvim-lua/plenary.nvim',
      -- 'nvim-telescope/telescope.nvim',
      -- 'akinsho/toggleterm.nvim',
    },
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    init = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>g', builtin.lsp_definitions, {})
      vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols, {})
      require('telescope').load_extension('hoogle')
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'luc-tielen/telescope_hoogle'
    }
  },
  {
    'hrsh7th/nvim-cmp',
    init = function()
      local cmp = require'cmp'
      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer', option = {
              get_bufnrs = function()
                  return vim.api.nvim_list_bufs()
              end
              },
          },
        }),
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm(),
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end,
          ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end,
        })
      })
      cmp.setup.cmdline({'/', '?'}, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
    end,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    }
  },
  {
    'nvim-treesitter/nvim-treesitter',
    init = function()
        require'nvim-treesitter.configs'.setup {
          ensure_installed = { "haskell", "lua" },
          sync_install = false,
          auto_install = false,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        }
    end
  },
  -- status bar
  {
    'nvim-lualine/lualine.nvim', 
    init = function()
      require'lualine'.setup()
    end,
    dependencies = {
      'kyazdani42/nvim-web-devicons'
    }
  },
  -- file manager
  {
    'nvim-tree/nvim-tree.lua',
    init = function() 
      require("nvim-tree").setup()
      local api = require "nvim-tree.api"
      vim.keymap.set('n', '<F8>', ':NvimTreeToggle<CR>')
    end,
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    }
  },
  -- tab line
  {
    'akinsho/bufferline.nvim', 
    init = function() 
      require("bufferline").setup()
      vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
      vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>')
    end,
    dependencies = {'nvim-tree/nvim-web-devicons'},
  },
  -- terminal
  {
    'akinsho/toggleterm.nvim', 
    version = "*", 
    opts = {
      direction = 'float',
      on_open = function(term)
        vim.cmd('startinsert!')
      end,
    }
  }

  -- see https://github.com/folke/lazy.nvim#-lazynvim for details.
}, { root = data_path, state = data_path .. '/lazy-state.json', lockfile = data_path .. '/lazy-lock.json' })
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.cmd'colorscheme murphy'
vim.keymap.set('n', '<Space>', '<PageDown> zz')
vim.keymap.set('n', '<S-Space>', '<PageUp> zz')


local ht = require('haskell-tools')
local bufnr = vim.api.nvim_get_current_buf()
local def_opts = { noremap = true, silent = true, buffer = bufnr, }
-- haskell-language-server relies heavily on codeLenses,
-- so auto-refresh (see advanced configuration) is enabled by default
vim.keymap.set('n', '<leader>ca', vim.lsp.codelens.run, opts)
-- Hoogle search for the type signature of the definition under the cursor
vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts)
-- Evaluate all code snippets
vim.keymap.set('n', '<leader>ea', ht.lsp.buf_eval_all, opts)
-- Toggle a GHCi repl for the current package
-- vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
vim.keymap.set('n', '<F4>', ht.repl.toggle, opts)
vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)

-- exit from insert mode on terminal
--vim.keymap.set('t', '<Esc>', '<C-\\><C-n>:q<CR>', opts)
vim.keymap.set('t', '<F4>', '<C-\\><C-n>:q<CR>', opts)
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', opts)
--vim.keymap.set('t', '<Esc>', ht.repl.toggle, opts)
-- ctrl-] - jump to tag
-- ctrl-[ - jump back
vim.keymap.set('n', '<C-[>', '<C-t>', opts)
