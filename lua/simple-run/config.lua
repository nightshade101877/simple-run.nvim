local M = {}
local defaults = {
  keymap = "<F2>",
  prompt_text = "Compile(1), Build(2) or Debug(3)?: ",
  add_flags = { -- flag options for compiled languages
    c = {
      compile_flags = {},
      linker_flags = {},
      debug_flags = {},
    },
    cpp = {
      compile_flags = {},
      linker_flags = {},
      debug_flags = {},
    },
    go = {
      compile_flags = {},
      linker_flags = {},
    },
  },
  languages = {
    c = {
      compile = function()
        local filepath = vim.fn.expand("%:p")
        local filename = vim.fn.expand("%:t:r")
        local flags = M.config.add_flags.c or { compile_flags = {}, linker_flags = {} }
        local compile_flags = table.concat(flags.compile_flags, " ")
        local linker_flags = table.concat(flags.linker_flags, " ")
        
        -- Build the compile command with flags
        local compile_cmd = string.format("gcc -g %s -o %s %s %s && ./%s",
          compile_flags,
          vim.fn.shellescape(filename),
          vim.fn.shellescape(filepath),
          linker_flags,
          vim.fn.shellescape(filename))
        
        -- Remove extra spaces if flags are empty
        compile_cmd = compile_cmd:gsub("%s+", " "):gsub("^%s+", "")
        return compile_cmd
      end,
      build = function()
        local c_files = vim.fn.globpath(".", "*.c", false, true)
        if #c_files < 2 then
          print("Need at least 2 files to build")
          return
        end
        local default_name = "program"
        local binary_name = vim.fn.input("Binary name: ", default_name)
        if binary_name == "" then
          binary_name = default_name
        end
        
        local flags = M.config.add_flags.c or { compile_flags = {}, linker_flags = {} }
        local compile_flags = table.concat(flags.compile_flags, " ")
        local linker_flags = table.concat(flags.linker_flags, " ")
        
        return "gcc -g " .. compile_flags .. " " .. table.concat(c_files, " ") .. " " .. linker_flags .. " -o " .. vim.fn.shellescape(binary_name) .. " && ./" .. vim.fn.shellescape(binary_name)
      end,
      debug = function()
        local filename = vim.fn.expand("%:t:r")
        local filepath = "./" .. filename
        local flags = M.config.add_flags.c or { debug_flags = {} }
        local debug_flags = table.concat(flags.debug_flags, " ")
        
        if vim.fn.executable(filepath) == 1 then
          return string.format("gdb -q %s ./%s", debug_flags, vim.fn.shellescape(filename))
        else
          vim.notify("Error. No executable found. Compile first!", vim.log.levels.ERROR)
        end
      end,
    },
    cpp = {
      compile = function()
        local filepath = vim.fn.expand("%:p")
        local filename = vim.fn.expand("%:t:r")
        vim.g.has_compiled = true
        
        local flags = M.config.add_flags.cpp or { compile_flags = {}, linker_flags = {} }
        local compile_flags = table.concat(flags.compile_flags, " ")
        local linker_flags = table.concat(flags.linker_flags, " ")
        
        local compile_cmd = string.format("g++ -g %s -o %s %s %s && ./%s",
          compile_flags,
          vim.fn.shellescape(filename),
          vim.fn.shellescape(filepath),
          linker_flags,
          vim.fn.shellescape(filename))
        
        compile_cmd = compile_cmd:gsub("%s+", " "):gsub("^%s+", "")
        return compile_cmd
      end,
      build = function()
        local cpp_files = vim.fn.globpath(".", "*.cpp", false, true)
        if #cpp_files < 2 then
          print("Need at least 2 files to build")
          return
        end
        local default_name = "program"
        local binary_name = vim.fn.input("Binary name: ", default_name)
        if binary_name == "" then
          binary_name = default_name
        end
        
        local flags = M.config.add_flags.cpp or { compile_flags = {}, linker_flags = {} }
        local compile_flags = table.concat(flags.compile_flags, " ")
        local linker_flags = table.concat(flags.linker_flags, " ")
        
        return "g++ -g " .. compile_flags .. " " .. table.concat(cpp_files, " ") .. " " .. linker_flags .. " -o " .. vim.fn.shellescape(binary_name) .. " && ./" .. vim.fn.shellescape(binary_name)
      end,
      debug = function()
        local filename = vim.fn.expand("%:t:r")
        local flags = M.config.add_flags.cpp or { debug_flags = {} }
        local debug_flags = table.concat(flags.debug_flags, " ")
        
        if vim.g.has_compiled then
          return string.format("gdb -q %s ./%s", debug_flags, filename)
        else
          vim.notify("Error. No executable found. Compile first!", vim.log.levels.ERROR)
        end
      end,
    },
    go = {
      compile = function()
        local filepath = vim.fn.expand("%:p")
        local flags = M.config.add_flags.go or { compile_flags = {}, linker_flags = {} }
        local compile_flags = table.concat(flags.compile_flags, " ")
        local linker_flags = table.concat(flags.linker_flags, " ")
        
        local go_cmd
        if compile_flags ~= "" or linker_flags ~= "" then
          go_cmd = string.format("go run -gcflags=\"%s\" -ldflags=\"%s\" %s",
            compile_flags,
            linker_flags,
            vim.fn.shellescape(filepath))
        else
          go_cmd = string.format("go run %s", vim.fn.shellescape(filepath))
        end
        
        return go_cmd
      end,
    },
    python = {
      compile = function()
        local filepath= vim.fn.expand("%:p")
        return string.format("python3 %s", vim.fn.shellescape(filepath))
      end,
       debug = function()
         local filepath = vim.fn.expand("%:p")
         return string.format("python3 -m pdb %s", vim.fn.shellescape(filepath))
       end,
    },
    sh = {
      compile = function()
        local filepath = vim.fn.expand("%:p")
        local filename = vim.fn.expand("%:t:r")
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
  
  if user_opts.add_flags then
    for lang, flags in pairs(user_opts.add_flags) do
      if M.config.add_flags[lang] then
        M.config.add_flags[lang] = vim.tbl_deep_extend("force", M.config.add_flags[lang], flags)
      else
        M.config.add_flags[lang] = flags
      end
    end
  end
end

function M.get()
  return M.config
end

return M
