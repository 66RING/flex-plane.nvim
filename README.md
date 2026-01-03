# Flex Plane

A simple Neovim plugin to manage sidebar windows that run any command/program.

## Features

- Create split windows (left/right/top/bottom)
- Run any terminal command or CLI tool
- Toggle, show, hide windows
- Keep buffers running in background
- **Remember window size** - your adjustments persist across toggle
- **Move window position** - quick shortcuts to reposition windows
- **Quickfix list** - manage all windows from quickfix panel

## Installation

Example with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  '66RING/flex-plane.nvim',
  config = function()
    require('flex_plane').setup({
      position = 'right',
      default_width = 30,
      default_height = 15,
      default_cmd = vim.o.shell,
    })
  end
}
```

## Usage

```lua
-- Toggle a window
require('flex_plane').toggle('zsh')
-- Close all windows
require('flex_plane').close_all()
-- List managed plane in qlist
require('flex_plane').list()
```

Recommended usage:

```lua
vim.api.nvim_create_user_command('AICode', function() require('flex_plane').toggle('claude') end , { desc = 'Open claude code.' })
```

### Move Window

```lua
-- Move current window to a position (must be in flex_plane window)
require('flex_plane').move('top')
require('flex_plane').move('bottom')
require('flex_plane').move('left')
require('flex_plane').move('right')
```

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `position` | string | `"right"` | Window position: `"left"`, `"right"`, `"top"`, `"bottom"` |
| `default_width` | number\|function | `30` | Default width for vertical splits |
| `default_height` | number\|function | `15` | Default height for horizontal splits |
| `default_cmd` | string | `vim.o.shell` | Default command to run |


## Keybindings Example

```lua
vim.api.nvim_create_user_command('AICode', function() require('flex_plane').toggle('claude') end , { desc = 'Open claude code.' })

vim.keymap.set('n', '<c-left>', function()
  require('flex_plane').move('left')
end, {})
vim.keymap.set('n', '<c-right>', function()
  require('flex_plane').move('right')
end, {})
vim.keymap.set('n', '<c-up>', function()
  require('flex_plane').move('top')
end, {})
vim.keymap.set('n', '<c-down>', function()
  require('flex_plane').move('bottom')
end, {})
```
