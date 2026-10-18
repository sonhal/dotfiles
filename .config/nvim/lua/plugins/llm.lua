-- Ad hoc LLM help while writing; the code is lua/llm.lua. A virtual plugin, so
-- lazy.nvim loads it on the keys or :LlmModel without anything to install.
return {
  'llm', -- no slash: a name, not a GitHub repo
  virtual = true,
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = 'LlmModel',
  keys = {
    { '<leader>ah', function() require('llm').help() end, mode = { 'n', 'v' }, desc = '[A]I: [H]elp (answer below)' },
    { '<leader>ar', function() require('llm').replace() end, mode = { 'n', 'v' }, desc = '[A]I: [R]eplace selection' },
  },
  config = function()
    require('llm').setup()
  end,
}
