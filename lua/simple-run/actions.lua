local config = require("simple-run.config")

local M = {}

function M.get_current_config()
  local ft = vim.bo.filetype
  if ft == "" then
    return nil, "No file type detected!"
  end
  
  local languages = config.get().languages
  local lang_config = languages[ft]
  
  if not lang_config then
    return nil, "No config for filetype: " .. ft
  end
  return lang_config, nil
end

function M.run()
  local lang_config, err = M.get_current_config()

  if err then
    vim.notify(err, vim.log.levels.WARN)
    return
  end
  
  local command
  local input
  local cfg = config.get()

  -- Check what actions are available
  local has_compile = lang_config.compile ~= nil
  local has_build = lang_config.build ~= nil
  local has_debug = lang_config.debug ~= nil

  if has_compile and has_build and has_debug then
    input = tonumber(vim.fn.input(cfg.prompt_text))
    if input == 1 then
      command = lang_config.compile()
    elseif input == 2 then
      command = lang_config.build()
    elseif input == 3 then
      command = lang_config.debug()
    else
      vim.notify("Invalid action", vim.log.levels.ERROR)
      return
    end
  else
    if lang_config.compile then
      command = lang_config.compile()
    elseif lang_config.build then
      command = lang_config.build()
    elseif lang_config.debug then
      command = lang_config.debug()
    end
  end

  if not command then
    vim.notify("Failed to generate command", vim.log.levels.ERROR)
    return
  end
  vim.cmd("w")
  vim.cmd("terminal " .. command)
end

return M
