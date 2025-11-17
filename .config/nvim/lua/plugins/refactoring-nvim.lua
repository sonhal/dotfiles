return {
  'ThePrimeagen/refactoring.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  lazy = false,
  opts = {},

  keys = {
    {
      '<leader>re',
      ':Refactor extract ',
      desc = 'Extract to function',
      mode = { 'x' },
    },
    {
      '<leader>rf',
      ':Refactor extract_to_file ',
      desc = 'Extract to file',
      mode = { 'x' },
    },
    {
      '<leader>rv',
      ':Refactor extract_var ',
      desc = 'Extract variable',
      mode = { 'x' },
    },
    {
      '<leader>rI',
      ':Refactor inline_func ',
      desc = 'Extract inline function',
      mode = { 'n' },
    },
    {
      '<leader>rb',
      ':Refactor extract_block ',
      desc = 'Extract block',
      mode = { 'n' },
    },
    {
      '<leader>rbf',
      ':Refactor extract_block_to_file ',
      desc = 'Extract block to file',
      mode = { 'n' },
    },
  },
}
