return {
  dir = vim.fn.stdpath 'config',
  name = 'launch-run',
  dependencies = {
    'preservim/vimux',
    'mfussenegger/nvim-dap',
  },
  keys = {
    { '<F6>', function() require('launch-run').run() end, desc = 'Launch: Run (no debugger)' },
    { '<leader>ll', function() require('launch-run').run() end, desc = '[L]aunch: Run config' },
    { '<leader>lr', function() require('launch-run').run_last() end, desc = '[L]aunch: [R]erun last' },
    { '<leader>lk', '<cmd>VimuxInterruptRunner<cr>', desc = '[L]aunch: [K]ill runner' },
    { '<leader>lc', '<cmd>VimuxCloseRunner<cr>', desc = '[L]aunch: [C]lose runner' },
  },
  config = function()
    local M = {}

    local function expand_variables(value)
      if type(value) == 'table' then
        local result = {}
        for k, v in pairs(value) do
          result[k] = expand_variables(v)
        end
        return result
      end
      if type(value) ~= 'string' then
        return value
      end
      local replacements = {
        ['${workspaceFolder}'] = vim.fn.getcwd(),
        ['${workspaceFolderBasename}'] = vim.fn.fnamemodify(vim.fn.getcwd(), ':t'),
        ['${file}'] = vim.fn.expand '%:p',
        ['${fileBasename}'] = vim.fn.expand '%:t',
        ['${fileBasenameNoExtension}'] = vim.fn.fnamemodify(vim.fn.expand '%:t', ':r'),
        ['${fileDirname}'] = vim.fn.expand '%:p:h',
        ['${relativeFile}'] = vim.fn.expand '%:.',
        ['${relativeFileDirname}'] = vim.fn.expand '%:.:h',
        ['${fileExtname}'] = vim.fn.expand '%:e',
      }
      for pattern, replacement in pairs(replacements) do
        value = value:gsub(vim.pesc(pattern), (replacement:gsub('%%', '%%%%')))
      end
      value = value:gsub('%${env:([%w_]+)}', function(var)
        return os.getenv(var) or ''
      end)
      return value
    end

    local function parse_env_file(path)
      path = expand_variables(path)
      local f = io.open(path, 'r')
      if not f then
        return {}
      end
      local env = {}
      for line in f:lines() do
        line = line:match '^%s*(.-)%s*$'
        if line ~= '' and not line:match '^#' then
          local key, val = line:match '^([%w_]+)%s*=%s*(.*)'
          if key then
            val = val:match '^"(.*)"$' or val:match "^'(.*)'$" or val
            env[key] = val
          end
        end
      end
      f:close()
      return env
    end

    local function build_env(config)
      local env = {}
      if config.envFile then
        local file_env = parse_env_file(config.envFile)
        for k, v in pairs(file_env) do
          env[k] = v
        end
      end
      if config.env then
        for k, v in pairs(config.env) do
          env[k] = expand_variables(v)
        end
      end
      return env
    end

    local function env_prefix(env)
      local parts = {}
      for k, v in pairs(env) do
        table.insert(parts, k .. '=' .. vim.fn.shellescape(v))
      end
      return parts
    end

    local function cwd_prefix(config)
      if config.cwd then
        return 'cd ' .. vim.fn.shellescape(expand_variables(config.cwd)) .. ' && '
      end
      return ''
    end

    M.runners = {}

    M.runners.go = function(config)
      local parts = env_prefix(build_env(config))
      table.insert(parts, 'go')
      table.insert(parts, 'run')
      if config.buildFlags and config.buildFlags ~= '' then
        table.insert(parts, expand_variables(config.buildFlags))
      end
      table.insert(parts, expand_variables(config.program or '.'))
      if config.args then
        for _, arg in ipairs(config.args) do
          table.insert(parts, vim.fn.shellescape(expand_variables(arg)))
        end
      end
      return cwd_prefix(config) .. table.concat(parts, ' ')
    end

    M.runners.debugpy = function(config)
      local parts = env_prefix(build_env(config))
      table.insert(parts, 'python3')
      table.insert(parts, expand_variables(config.program or ''))
      if config.args then
        for _, arg in ipairs(config.args) do
          table.insert(parts, vim.fn.shellescape(expand_variables(arg)))
        end
      end
      return cwd_prefix(config) .. table.concat(parts, ' ')
    end
    M.runners.python = M.runners.debugpy

    M.runners.codelldb = function(config)
      local parts = env_prefix(build_env(config))
      table.insert(parts, 'cargo')
      table.insert(parts, 'run')
      if config.args and #config.args > 0 then
        table.insert(parts, '--')
        for _, arg in ipairs(config.args) do
          table.insert(parts, vim.fn.shellescape(expand_variables(arg)))
        end
      end
      return cwd_prefix(config) .. table.concat(parts, ' ')
    end
    M.runners.lldb = M.runners.codelldb

    local function fallback_runner(config)
      local parts = env_prefix(build_env(config))
      local program = expand_variables(config.program or '')
      if program == '' then
        return nil
      end
      table.insert(parts, program)
      if config.args then
        for _, arg in ipairs(config.args) do
          table.insert(parts, vim.fn.shellescape(expand_variables(arg)))
        end
      end
      return cwd_prefix(config) .. table.concat(parts, ' ')
    end

    function M.run()
      local ok, vscode = pcall(require, 'dap.ext.vscode')
      if not ok then
        vim.notify('nvim-dap is required for launch-run', vim.log.levels.ERROR)
        return
      end

      local configs = vscode.getconfigs()
      configs = vim.tbl_filter(function(c)
        return c.request == 'launch'
      end, configs)

      if #configs == 0 then
        vim.notify('No launch configurations found in .vscode/launch.json', vim.log.levels.WARN)
        return
      end

      local function dispatch(config)
        if not config then
          return
        end
        local mt = getmetatable(config)
        if mt and mt.__call then
          config = config()
        end

        local runner = M.runners[config.type]
        local cmd
        if runner then
          cmd = runner(config)
        else
          vim.notify('No runner for type "' .. (config.type or '?') .. '", trying raw command', vim.log.levels.WARN)
          cmd = fallback_runner(config)
        end
        if not cmd then
          vim.notify('Could not build command for "' .. config.name .. '"', vim.log.levels.ERROR)
          return
        end

        local success, err = pcall(vim.fn.VimuxRunCommand, cmd)
        if not success then
          vim.notify('Vimux error (are you in tmux?): ' .. tostring(err), vim.log.levels.ERROR)
        end
      end

      if #configs == 1 then
        dispatch(configs[1])
      else
        vim.ui.select(configs, {
          prompt = 'Run profile:',
          format_item = function(c)
            return c.name
          end,
        }, dispatch)
      end
    end

    function M.run_last()
      local success, err = pcall(vim.fn.VimuxRunLastCommand)
      if not success then
        vim.notify('No previous launch command (or not in tmux): ' .. tostring(err), vim.log.levels.ERROR)
      end
    end

    package.loaded['launch-run'] = M
  end,
}
