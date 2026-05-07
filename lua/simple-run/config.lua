local M = {}
local defaults = {
  keymap = "<F2>",
  prompt_text = "Compile(1), Build(2) or Debug(3)?: ",
  languages = {
    c = {
      compile = function()
        local filepath= vim.fn.expand("%:p")
        local filename = vim.fn.expand("%:r")
        return string.format("gcc -g -o %s %s && ./%s",
          vim.fn.fnamemodify(filename, ":t"),
          vim.fn.shellescape(filepath),
          vim.fn.fnamemodify(filename, ":t"))
      end,
      build = function()
        local c_files = vim.fn.globpath(".", "*.c", false, true)
        if #c_files < 2 then
          print("Need at least 2 files to build")
          return
        end
        return "gcc -g " .. table.concat(c_files, " ") .. " -o program && ./program"
      end,
      debug = function()
        local filename = vim.fn.expand("%:r")
        return string.format("gdb -q %s", vim.fn.fnamemodify(filename,":t"))
      end,
    },
    go = {
      compile = function()
        local filepath = vim.fn.expand("%:p")
        return string.format("go run %s", filepath)
      end,
    },
    python = {
      compile = function()
        local filepath= vim.fn.expand("%:p")
        return string.format("python3 %s", filepath)
      end,
    },
    sh = {
      compile = function()
        local filepath = vim.fn.expand("%:p")
        local filename = vim.fn.expand("%")
        local perm = vim.fn.getfperm(filepath)
        local executable = perm:sub(3, 3) == "x"
          or perm:sub(6, 6) == "x"
          or perm:sub(9, 9) == "x"
        if executable then
          return filepath
        end
        local result = vim.system({ "chmod", "744", filepath }, { text = true }):wait()
        if result.code == 0 then
          vim.notify("Added execute permission to " .. filename, vim.log.levels.INFO)
          return filepath
        else
          vim.notify("Could not set execute permission! " .. (result.stderr or "unknown"), vim.log.levels.ERROR)
          return nil
        end
      end,
    },
  },
}

M.config = vim.deepcopy(defaults)


function M.setup(user_opts)
  user_opts = user_opts or {}
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_opts)
  
  if user_opts.languages then
    for lang, user_lang_config in pairs(user_opts.languages) do
      if M.config.languages[lang] then
        M.config.languages[lang] = vim.tbl_deep_extend("force", M.config.languages[lang], user_lang_config)
      else
        M.config.languages[lang] = user_lang_config
      end
    end
  end
end

function M.get()
  return M.config
end

return M
