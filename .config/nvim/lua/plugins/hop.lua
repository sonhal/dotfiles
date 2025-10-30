return {
  'smoka7/hop.nvim',
  version = '*',
  opts = {
    keys = 'etovxqpdygfblzhckisuran',
  },
  keys = {
    {
      '<leader>m',
      function()
        require('hop').hint_words {}
      end,
      desc = 'Hint all words in buffer (Hop)',
    },
  },
}
