return {
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
    'TmuxNavigatorProcessList',
  },
  keys = {
    { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>', desc = 'Move focus left (tmux aware)' },
    { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>', desc = 'Move focus down (tmux aware)' },
    { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>', desc = 'Move focus up (tmux aware)' },
    { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>', desc = 'Move focus right (tmux aware)' },
    { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>', desc = 'Move focus to previous (tmux aware)' },
  },
}
