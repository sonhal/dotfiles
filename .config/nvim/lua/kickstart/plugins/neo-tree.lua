-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'echasnovski/mini.icons', -- not strictly required, but recommended (mocks nvim-web-devicons)
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    -- document_symbols is an LSP outline of the current file, shown as its own tab
    sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
    -- Tabs at the top of the window for switching between the sources above (or use < and >)
    source_selector = {
      winbar = true,
    },
    filesystem = {
      -- Keep the tree in sync with the file you are editing
      follow_current_file = { enabled = true },
      -- Collapse chains of single-child directories into one row (e.g. src/main/java/com/foo)
      group_empty_dirs = true,
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
