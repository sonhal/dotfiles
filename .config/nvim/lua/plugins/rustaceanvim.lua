return {
  'mrcjkb/rustaceanvim',
  version = '^9',
  lazy = false, -- the plugin is already lazy, do not lazy-load it
  init = function()
    vim.g.rustaceanvim = {
      server = {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      },
    }
  end,
}
