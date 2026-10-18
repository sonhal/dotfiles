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
    { '<leader>dc', function() require('dap').continue() end, desc = 'Start / Continue' },
    { '<leader>ds', '<cmd>DapViewJump scopes<cr>', desc = 'Scopes (variables)' },
    { '<leader>dr', '<cmd>DapViewJump repl<cr>', desc = 'REPL (expressions)' },
    { '<leader>dt', '<cmd>DapViewJump threads<cr>', desc = 'Threads / Stack frames' },
    { '<leader>dv', '<cmd>DapViewToggle<cr>', desc = 'Toggle debug view' },
    { '<leader>dh', function() require('dap.ui.widgets').hover() end, desc = 'Inspect value under cursor' },
    {
      '<leader>dw',
      function()
        vim.ui.input({ prompt = 'Watch expression: ', default = vim.fn.expand '<cexpr>' }, function(expression)
          if expression and expression:match '%S' then
            require('dap-view').add_expr(expression)
          end
        end)
      end,
      desc = 'Watch expression',
    },
    { '<leader>dg', function() require('dap').run_to_cursor() end, desc = 'Go to cursor (while paused)' },
    {
      '<leader>dl',
      function()
        vim.ui.input({ prompt = 'Logpoint message: ' }, function(message)
          if message and message:match '%S' then
            require('dap').set_breakpoint(nil, nil, message)
          end
        end)
      end,
      desc = 'Logpoint',
    },
    { '<leader>dx', function() require('dap').terminate() end, desc = 'Terminate program' },
    {
      '<leader>dd',
      function()
        local dap = require 'dap'
        dap.disconnect({ terminateDebuggee = false }, function() dap.close() end)
      end,
      desc = 'Disconnect (request program stays running)',
    },
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
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#c23127' })
    vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#e5ac00' })
    vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#737373' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#2e4d2e' })

    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '◐', texthl = 'DapBreakpointCondition' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DapBreakpointRejected' })
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine' })

    local dap = require 'dap'

    dap.defaults.fallback.switchbuf = 'usevisible,usetab,newtab'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {
        delve = function() end,
        python = function() end, -- configured by nvim-dap-python below
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
      dap_configurations = {
        {
          type = 'go',
          name = 'Attach to Delve',
          request = 'attach',
          mode = 'remote',
          host = '127.0.0.1',
          port = 38697,
        },
      },
      delve = {
        detached = vim.fn.has 'win32' == 0,
        output_mode = 'remote',
      },
    }
    require('dap-python').setup(vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python')
  end,
}
