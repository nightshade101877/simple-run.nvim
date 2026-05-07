local config = require("simple-run.config")
local actions = require("simple-run.actions")

local M = {}

function M.setup(opts)
  config.setup(opts)
  local keymap = config.get().keymap
  if keymap then
    vim.keymap.set("n", keymap, function()
      M.run()
    end, { desc = "Run/Build/Debug current file" })
  end
  
  return M
end

function M.run()
  actions.run()
end

-- Function to add language at runtime
function M.add_language(filetype, language_config)
  local cfg = config.get()
  cfg.languages[filetype] = vim.tbl_deep_extend("force", cfg.languages[filetype] or {}, language_config)
end

-- Function to get language config
function M.get_language(filetype)
  return config.get().languages[filetype]
end

return M
