return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'igorlfs/nvim-dap-view',

    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    {
      '<F7>',
      '<cmd>DapViewToggle<cr>',
      desc = 'Debug: Toggle debug view',
    },
  },
  config = function()
    local dap = require 'dap'

    dap.defaults.fallback.switchbuf = 'usevisible,usetab,newtab'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {
        delve = function() end,
      },
      ensure_installed = {
        'delve',
        'python',
      },
    }

    require('dap-view').setup {
      auto_toggle = true,
      virtual_text = {
        enabled = true,
      },
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'dap-view', 'dap-view-watches', 'dap-repl' },
      callback = function()
        vim.opt_local.spell = false
      end,
    })

    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
        output_mode = 'remote',
      },
    }
    require('dap-python').setup 'python3'
  end,
}
