-- Ad hoc LLM help while writing, against an OpenAI-style chat completions API
-- (OpenRouter). Started from https://github.com/yacineMTB/dingllm.nvim; the
-- keys and the :LlmModel command are in lua/plugins/llm.lua.
--
-- help() and replace() ask for an instruction on the command line, then send
-- it with the visual selection (or, in normal mode, the lines up to the
-- cursor for help, the current line for replace):
--   help()     streams the answer onto new lines below the text
--   replace()  streams a replacement in place of the text
-- <Esc> in normal mode, in that buffer, stops a running answer. :LlmModel
-- [name] changes the model and remembers it (no name: pick one). Needs
-- OPENROUTER_API_KEY in the environment nvim was started from.
local M = {}

local Job = require 'plenary.job'

local url = 'https://openrouter.ai/api/v1/chat/completions'
local key_name = 'OPENROUTER_API_KEY'
-- Any slug from https://openrouter.ai/models. :LlmModel saves its choice in
-- the state dir, which wins over this default.
local model = 'qwen/qwen3.8-flash'
local model_file = vim.fn.stdpath 'state' .. '/llm_model'
do
  local ok, saved = pcall(vim.fn.readfile, model_file)
  if ok and saved[1] and vim.trim(saved[1]) ~= '' then
    model = vim.trim(saved[1])
  end
end

local replace_prompt = 'You are an expert software developer who writes concise code. Rewrite the code/markup/config you are sent, following the instruction. '
  .. 'Output only the replacement code/markup/config, exactly as it should appear in the file, keeping the original indentation. '
  .. 'No commentary, no explanations, never markdown fences or backticks around it.'
local help_prompt = 'You are a helpful coding assistant, expert in writing concise code. You get an instruction and the code/config/markup I am working on. '
  .. 'Your answer is inserted into the file directly below it, so output only the new lines that go there: '
  .. 'never repeat the code you were sent, never use markdown fences or backticks, no preamble. '
  .. 'Answer in plain code/config/markup that fits the file. '
  .. "If the instruction is a question, answer it briefly as a comment in the file's comment syntax."

local ns = vim.api.nvim_create_namespace 'llm_stream'
local active_job = nil

local function notify_error(msg)
  vim.schedule(function()
    vim.notify('llm: ' .. msg, vim.log.levels.ERROR)
  end)
end

-- ── Text and insertion point ──

-- The text to send and where the answer goes: the selection while in visual
-- mode, otherwise the lines up to the cursor (help) or the current line
-- (replace). Rows are 0-based, end_col exclusive.
local function capture(replace)
  local mode = vim.fn.mode()
  local buf = vim.api.nvim_get_current_buf()
  if mode == 'v' then
    local region = vim.fn.getregionpos(vim.fn.getpos 'v', vim.fn.getpos '.', { type = 'v', exclusive = false })
    local s, e = region[1][1], region[#region][2]
    local last = vim.api.nvim_buf_get_lines(buf, e[2] - 1, e[2], true)[1]
    -- getregionpos ends on the last character's first byte; include all of it.
    local end_col = math.min(e[3] - 1 + vim.fn.byteidx(last:sub(e[3]), 1), #last)
    if end_col < e[3] then
      end_col = #last
    end
    return {
      buf = buf,
      text = table.concat(vim.api.nvim_buf_get_text(buf, s[2] - 1, s[3] - 1, e[2] - 1, end_col, {}), '\n'),
      linewise = false,
      srow = s[2] - 1,
      scol = s[3] - 1,
      erow = e[2] - 1,
      ecol = end_col,
    }
  end
  local srow, erow
  if mode == 'V' or mode == '\22' then
    srow, erow = vim.fn.line 'v' - 1, vim.fn.line '.' - 1
    if srow > erow then
      srow, erow = erow, srow
    end
  else
    erow = vim.fn.line '.' - 1
    srow = replace and erow or 0
  end
  return {
    buf = buf,
    text = table.concat(vim.api.nvim_buf_get_lines(buf, srow, erow + 1, true), '\n'),
    linewise = true,
    srow = srow,
    erow = erow,
  }
end

-- How the insertion point looks while an answer streams: a sign on its line
-- and, inline at the point itself, "waiting…" until the first text arrives,
-- then a cursor.
local function mark_opts(waiting, id)
  return {
    id = id,
    right_gravity = true,
    virt_text = { waiting and { '▍waiting for ' .. model:gsub('^.*/', '') .. '…', 'Comment' } or { '▍', 'DiagnosticInfo' } },
    virt_text_pos = 'inline',
    sign_text = 'AI',
    sign_hl_group = 'DiagnosticInfo',
  }
end

-- Clears the target (replace) or opens a line below it (help) and returns an
-- extmark there. The mark has right gravity, so it moves past each inserted
-- chunk and the next one goes after it.
local function prepare(target, replace)
  local buf = target.buf
  local row, col
  if replace and target.linewise then
    vim.api.nvim_buf_set_lines(buf, target.srow, target.erow + 1, true, { '' })
    row, col = target.srow, 0
  elseif replace then
    vim.api.nvim_buf_set_text(buf, target.srow, target.scol, target.erow, target.ecol, {})
    row, col = target.srow, target.scol
  else
    vim.api.nvim_buf_set_lines(buf, target.erow + 1, target.erow + 1, true, { '' })
    row, col = target.erow + 1, 0
  end
  return vim.api.nvim_buf_set_extmark(buf, ns, row, col, mark_opts(true))
end

local function write_chunk(buf, mark, str)
  if not vim.api.nvim_buf_is_loaded(buf) then
    return
  end
  local pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns, mark, {})
  if not pos[1] then
    return
  end
  vim.api.nvim_buf_call(buf, function()
    pcall(vim.cmd.undojoin) -- one undo step for the whole answer
    vim.api.nvim_buf_set_text(buf, pos[1], pos[2], pos[1], pos[2], vim.split(str, '\n'))
  end)
  pos = vim.api.nvim_buf_get_extmark_by_id(buf, ns, mark, {})
  vim.api.nvim_buf_set_extmark(buf, ns, pos[1], pos[2], mark_opts(false, mark))
end

-- ── Request ──

local function stop()
  if active_job then
    -- Clear it first: shutdown runs on_exit right away, which must see a cancel.
    local job = active_job
    active_job = nil
    job:shutdown()
    vim.notify 'llm: cancelled'
  end
end

local function finish(buf, mark)
  vim.schedule(function()
    if vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_del_extmark(buf, ns, mark)
      pcall(vim.keymap.del, 'n', '<Esc>', { buffer = buf })
    end
  end)
end

-- The OpenAI-style stream: "data: {json}" lines, ending with "data: [DONE]".
-- curl appends the HTTP status as one more data line, because an error reply
-- (bad key or model) comes as a plain JSON body, not as stream events.
local function handle_line(line, buf, mark)
  local data = line:match '^data: (.+)$'
  if not data or data == '[DONE]' then
    return
  end
  local ok, json = pcall(vim.json.decode, data)
  if not ok or type(json) ~= 'table' then
    return
  end
  if json.http_status then
    if json.http_status >= 400 then
      notify_error('HTTP ' .. json.http_status .. ' from ' .. url:match '^https?://([^/]+)' .. ' (check the key and model)')
    end
  elseif json.error then
    notify_error(json.error.message or data)
  elseif json.choices and json.choices[1] and json.choices[1].delta then
    local content = json.choices[1].delta.content
    if type(content) == 'string' and content ~= '' then
      vim.schedule(function()
        write_chunk(buf, mark, content)
      end)
    end
  end
end

local function curl_args(system_prompt, prompt)
  local body = vim.json.encode {
    model = model,
    stream = true,
    messages = { { role = 'system', content = system_prompt }, { role = 'user', content = prompt } },
  }
  local args = {
    '-sS', -- no progress meter on stderr, but keep curl's errors
    '-N',
    '-w',
    '\ndata: {"http_status":%{http_code}}\n',
    '-X',
    'POST',
    '-H',
    'Content-Type: application/json',
    '-d',
    body,
  }
  local key = os.getenv(key_name)
  if key then
    vim.list_extend(args, { '-H', 'Authorization: Bearer ' .. key })
  end
  table.insert(args, url)
  return args
end

local function send(target, instruction, replace)
  stop()
  local mark = prepare(target, replace)
  local ft = vim.bo[target.buf].filetype
  -- 'commentstring' is the file's exact comment syntax (e.g. "-- %s"), for
  -- answers to questions; more reliable than the model guessing from ft.
  local cs = vim.bo[target.buf].commentstring
  local prompt = 'Instruction: ' .. instruction
    .. (cs:find '%%s' and ('\nComments in this file look like: ' .. cs:gsub('%%s', 'comment text')) or '')
    .. '\n\nText' .. (ft ~= '' and (' (from a ' .. ft .. ' file)') or '') .. ':\n' .. target.text

  local job
  local stderr = {}
  job = Job:new {
    command = 'curl',
    args = curl_args(replace and replace_prompt or help_prompt, prompt),
    on_stdout = function(_, line)
      handle_line(line, target.buf, mark)
    end,
    on_stderr = function(_, line)
      table.insert(stderr, line)
    end,
    on_exit = function(_, code)
      -- A job cancelled with <Esc> is no longer the active one.
      if active_job == job then
        active_job = nil
        if code ~= 0 then
          notify_error('curl failed (exit ' .. code .. '): ' .. table.concat(stderr, ' '))
        end
      end
      finish(target.buf, mark)
    end,
  }
  active_job = job
  job:start()
  vim.keymap.set('n', '<Esc>', function()
    stop()
    vim.cmd.nohlsearch()
  end, { buffer = target.buf, desc = 'llm: cancel' })
end

local function invoke(replace)
  if not os.getenv(key_name) then
    notify_error(key_name .. ' is not set')
    return
  end
  local target = capture(replace)
  if vim.fn.mode():match '^[vV\22]' then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
  end
  vim.ui.input({ prompt = replace and 'AI replace: ' or 'AI add: ' }, function(instruction)
    -- <Esc> on the prompt cancels; an empty help prompt still asks for help with the text.
    if instruction == nil or (replace and instruction == '') then
      return
    end
    if instruction == '' then
      instruction = 'Help me with this.'
    end
    send(target, instruction, replace)
  end)
end

function M.help()
  invoke(false)
end

function M.replace()
  invoke(true)
end

-- ── :LlmModel ──

-- OpenRouter's model list (public, no key needed), fetched once in setup for
-- the picker and completion.
local models = nil

local function fetch_models(on_done)
  vim.system({ 'curl', '-sS', '--max-time', '15', 'https://openrouter.ai/api/v1/models' }, { text = true }, function(res)
    local ok, json = pcall(vim.json.decode, res.stdout or '')
    if res.code ~= 0 or not ok or type(json) ~= 'table' or type(json.data) ~= 'table' then
      notify_error('could not load the model list: ' .. vim.trim(res.stderr or ''))
      return
    end
    local ids = {}
    for _, m in ipairs(json.data) do
      table.insert(ids, m.id)
    end
    table.sort(ids)
    models = ids
    if on_done then
      vim.schedule(on_done)
    end
  end)
end

local function set_model(id)
  model = id
  if vim.fn.writefile({ model }, model_file) ~= 0 then
    notify_error('could not save the model to ' .. model_file)
  end
  vim.notify('llm: model ' .. model)
end

local function pick()
  vim.ui.select(models, { prompt = 'Model (now ' .. model .. ')' }, function(choice)
    if choice then
      set_model(choice)
    end
  end)
end

function M.setup()
  fetch_models()
  vim.api.nvim_create_user_command('LlmModel', function(cmd)
    if cmd.args ~= '' then
      set_model(cmd.args)
    elseif models then
      pick()
    else
      vim.notify 'llm: loading the model list…'
      fetch_models(pick)
    end
  end, {
    nargs = '?',
    desc = 'Set the LLM model; no argument opens a picker',
    complete = function(lead)
      return vim.tbl_filter(function(id)
        return id:find(lead, 1, true) ~= nil
      end, models or {})
    end,
  })
end

return M
