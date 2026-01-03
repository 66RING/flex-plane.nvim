# Flex Plane

A simple Neovim plugin to create a sidebar window that runs any command/program.

## Features

- Create sidebar windows (left or right)
- Run any terminal command or CLI tool
- Toggle windows open/close
- Support multiple windows
- Configurable width, position, and border

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'yourusername/flex_plane.nvim',
  config = function()
    require('flex_plane').setup({
      width = 80,
      position = 'right',
      border = 'single',
      default_cmd = vim.o.shell,
      close_on_exit = false,
    })
  end
}
```

## Usage

### Basic Usage

```lua
-- Open with default command (shell)
require('flex_plane').open()

-- Open with specific command
require('flex_plane').open('lazygit')

-- Open with options
require('flex_plane').open('htop', { width = 60, position = 'left' })
```

### Toggle

```lua
-- Toggle a window
require('flex_plane').toggle('lazygit')
```

### Close

```lua
-- Close specific window (returns window id)
local id = require('flex_plane').open('node')
require('flex_plane').close(id)

-- Close all windows
require('flex_plane').close_all()
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `width` | number\|function | `80` | Window width in columns (or function returning number) |
| `position` | string | `"right"` | Window position: `"left"` or `"right"` |
| `border` | string\|table | `"single"` | Border style (see `:h nvim_open_win`) |
| `default_cmd` | string | `vim.o.shell` | Default command to run |
| `close_on_exit` | boolean | `false` | Auto-close window when command exits |

## Example Commands

```lua
-- Git UI
require('flex_plane').open('lazygit')

-- Process monitor
require('flex_plane').open('htop')

-- Python REPL
require('flex_plane').open('python3')

-- Node.js REPL
require('flex_plane').open('node')

-- Build tool
require('flex_plane').open('npm run dev')
```

## Keybindings Example

```lua
vim.keymap.set('n', '<leader>tt', function()
  require('flex_plane').toggle()
end, { desc = 'Toggle terminal' })

vim.keymap.set('n', '<leader>tg', function()
  require('flex_plane').toggle('lazygit')
end, { desc = 'Toggle lazygit' })

vim.keymap.set('n', '<leader>th', function()
  require('flex_plane').toggle('htop')
end, { desc = 'Toggle htop' })
```
