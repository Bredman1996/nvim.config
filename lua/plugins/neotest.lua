return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'Issafalcon/neotest-dotnet',
    },
    config = function()
      local neotest = require 'neotest'

      neotest.setup {
        adapters = {
          require 'neotest-dotnet' {
            -- automatically finds .slnx / .sln or csproj
            -- optional: pass additional args to dotnet test
            args = { '--no-build' },
          },
        },
        quickfix = {
          enabled = true, -- open results in quickfix
          open = false, -- set true to open automatically
        },
        status = {
          virtual_text = true, -- shows test results inline
        },
      }

      -- Keymaps for neotest
      local opts = { noremap = true, silent = true }

      -- Run nearest test
      vim.keymap.set('n', '<Leader>tn', function()
        neotest.run.run { strategy = 'dap' } -- runs in dap if possible
      end, opts)

      -- Run all tests in current file
      vim.keymap.set('n', '<Leader>tf', function()
        neotest.run.run(vim.fn.expand '%')
      end, opts)

      -- Run all tests in project
      vim.keymap.set('n', '<Leader>tp', function()
        neotest.run.run { vim.fn.getcwd() }
      end, opts)

      -- Debug nearest test
      vim.keymap.set('n', '<Leader>td', function()
        neotest.run.run { strategy = 'dap' }
      end, opts)

      -- Show test summary in floating window
      vim.keymap.set('n', '<Leader>ts', function()
        neotest.summary.toggle()
      end, opts)

      -- Show test output for last run test
      vim.keymap.set('n', '<Leader>to', function()
        neotest.output.open { enter = true }
      end, opts)
    end,
  },
}
