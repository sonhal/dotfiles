-- Started once per Java buffer. nvim-jdtls handles reusing the running client.
local ok, jdtls = pcall(require, 'jdtls')
if not ok then
  return
end

local mason = vim.fn.stdpath 'data' .. '/mason/packages'
local jdtls_path = mason .. '/jdtls'
if vim.fn.executable(jdtls_path .. '/bin/jdtls') == 0 then
  vim.notify('jdtls not installed, run :MasonInstall jdtls', vim.log.levels.WARN)
  return
end

local root_markers = { 'gradlew', 'mvnw', 'settings.gradle', 'settings.gradle.kts', 'pom.xml', '.git' }
local root_dir = vim.fs.root(0, root_markers)
if not root_dir then
  return
end

-- One workspace per project so jdtls does not mix up projects.
local workspace = vim.fn.stdpath 'cache' .. '/jdtls/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

-- Debug adapter and test runner bundles (installed by Mason).
local bundles = {}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true), '\n', { trimempty = true }))
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. '/java-test/extension/server/*.jar', true), '\n', { trimempty = true }))

local config = {
  cmd = {
    jdtls_path .. '/bin/jdtls',
    '--jvm-arg=-javaagent:' .. jdtls_path .. '/lombok.jar',
    '-data',
    workspace,
  },
  root_dir = root_dir,
  capabilities = require('blink.cmp').get_lsp_capabilities(),
  settings = {
    java = {
      signatureHelp = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          'org.junit.jupiter.api.Assertions.*',
          'org.assertj.core.api.Assertions.*',
          'org.mockito.Mockito.*',
        },
      },
      sources = {
        organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
      },
      codeGeneration = {
        toString = { template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}' },
        useBlocks = true,
      },
      inlayHints = { parameterNames = { enabled = 'all' } },
    },
  },
  init_options = {
    bundles = bundles,
  },
  on_attach = function(_, bufnr)
    -- Debugging and test running through the bundles above.
    jdtls.setup_dap { hotcodereplace = 'auto' }
    require('jdtls.dap').setup_dap_main_class_configs()

    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
    end
    map('<leader>jo', jdtls.organize_imports, '[O]rganize imports')
    map('<leader>jv', jdtls.extract_variable, 'Extract [V]ariable')
    map('<leader>jv', function() jdtls.extract_variable(true) end, 'Extract [V]ariable', 'v')
    map('<leader>jc', jdtls.extract_constant, 'Extract [C]onstant')
    map('<leader>jc', function() jdtls.extract_constant(true) end, 'Extract [C]onstant', 'v')
    map('<leader>jm', function() jdtls.extract_method(true) end, 'Extract [M]ethod', 'v')
    map('<leader>jt', jdtls.test_nearest_method, '[T]est nearest method')
    map('<leader>jT', jdtls.test_class, '[T]est class')
  end,
}

jdtls.start_or_attach(config)
