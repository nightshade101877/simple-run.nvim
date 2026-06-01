# simple-run.nvim

A lightweight Neovim plugin that lets you run, build, and debug code in multiple languages with a single keypress.

## Features

- ⚡ **Quick Execution** - Run and build files instantly without leaving your editor
- 🔧 **Highly Configurable** - Easily customize or add support for new languages
- 🎯 **Sensible Defaults** - Works out of the box with zero configuration required
- 🐛 **Debug Ready** - Integrated debugging support for supported languages
- 🌍 **Multi-Language Support** - Supports Go, C, C++, Bash, Python, and more

## Supported Languages

By default, simple-run.nvim supports:

- Go
- C
- C++
- Bash
- Python

## Installation

### Using lazy.nvim

```lua
{
  "mvera-karisa/simple-run.nvim",
  config = function()
    require("simple-run").setup({
      keymap = "your_desired_keybind"
    })
  end
}
```

### Using packer.nvim

```lua
use {
  "mvera-karisa/simple-run.nvim",
  config = function()
    require("simple-run").setup({
      keymap = "your_desired_keybind"
    })
  end
}
```

## Configuration

The plugin comes with sensible defaults but can be fully customized:

```lua
require("simple-run").setup({
  keymap = "<leader>r",  -- Default keybind for running files
  -- Additional configuration options here
})
```

## Usage

1. Open any supported file in Neovim
2. Press your configured keybind to run or build the file
3. Output appears in a terminal window

## Adding Custom Languages

You can extend simple-run.nvim with support for additional languages by modifying your configuration.

```lua
require("simple-run").setup({
languages = {
python = {
compile = function()
return "pyhton" .. vim.fn.expand("%:P")
end}}
})
```

## License

MIT
