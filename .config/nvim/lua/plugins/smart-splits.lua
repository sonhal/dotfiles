-- Move and resize across Neovim windows and tmux panes with the same keys.
-- The tmux half is the C-hjkl/M-hjkl bindings in ~/.config/tmux/tmux.conf;
-- tmux's select-pane wraps at edges, so keep `at_edge = 'wrap'`.
local function ss(fn)
  return function()
    require('smart-splits')[fn]()
  end
end

return {
  'smart-splits-nvim/smart-splits.nvim',
  version = '^3.0.0',
  -- Must not be lazy loaded: the backend tells tmux this pane runs Neovim
  -- (`@pane-is-vim`) when it loads. Until then tmux swallows <C-hjkl>.
  lazy = false,
  dependencies = {
    { 'smart-splits-nvim/backend-tmux', main = 'smart-splits-backend-tmux' },
  },
  opts = {
    mux = { backend = 'smart-splits-backend-tmux' },
    move = { at_edge = 'wrap' },
  },
  keys = {
    { '<C-h>', ss 'move_cursor_left', desc = 'Move focus left (tmux aware)' },
    { '<C-j>', ss 'move_cursor_down', desc = 'Move focus down (tmux aware)' },
    { '<C-k>', ss 'move_cursor_up', desc = 'Move focus up (tmux aware)' },
    { '<C-l>', ss 'move_cursor_right', desc = 'Move focus right (tmux aware)' },
    { '<M-h>', ss 'resize_left', desc = 'Resize left (tmux aware)' },
    { '<M-j>', ss 'resize_down', desc = 'Resize down (tmux aware)' },
    { '<M-k>', ss 'resize_up', desc = 'Resize up (tmux aware)' },
    { '<M-l>', ss 'resize_right', desc = 'Resize right (tmux aware)' },
  },
}
