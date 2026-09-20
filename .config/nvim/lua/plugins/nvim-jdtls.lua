-- Java: jdtls is started by ftplugin/java.lua via nvim-jdtls, not by lspconfig.
-- nvim-jdtls adds organize imports, extract refactorings, test running and debugging on top of plain jdtls.
return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  dependencies = { 'mfussenegger/nvim-dap' },
}
