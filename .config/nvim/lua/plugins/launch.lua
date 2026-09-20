return {
  'preservim/vimux',
  dependencies = { 'mfussenegger/nvim-dap' },
  keys = {
    { '<F6>', function() require('launch_run').run() end, desc = 'Launch: Run (no debugger)' },
    { '<leader>ll', function() require('launch_run').run() end, desc = '[L]aunch: Run config' },
    { '<leader>lr', function() require('launch_run').run_last() end, desc = '[L]aunch: [R]erun last' },
    { '<leader>lk', '<cmd>VimuxInterruptRunner<cr>', desc = '[L]aunch: [K]ill runner' },
    { '<leader>lc', '<cmd>VimuxCloseRunner<cr>', desc = '[L]aunch: [C]lose runner' },
  },
}
