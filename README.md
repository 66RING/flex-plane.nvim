# Flex Plane

A simple Neovim plugin to manage sidebar windows that run any command/program.

## Features

- Create split windows (left/right/top/bottom)
- Run any terminal command or CLI tool
- Toggle, show, hide windows
- Keep buffers running in background
- **Remember window size** - your adjustments persist across toggle
- **Fixed size windows** - protected from other plugins' auto-resize
- **Move window position** - quick shortcuts to reposition windows
- **Quickfix list** - manage all windows from quickfix panel

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'yourusername/flex_plane.nvim',
  config = function()
    require('flex_plane').setup({
      position = 'right',
      default_width = 80,
      default_height = 20,
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

-- Open at specific position
require('flex_plane').open('htop', { position = 'bottom' })
```

### Toggle

```lua
-- Toggle a window (open if closed, close if open)
-- Size is remembered when toggling!
require('flex_plane').toggle('lazygit')
```

### Show/Hide

```lua
-- Show an existing window in a split (restores saved size)
local id = 1
require('flex_plane').show(id)

-- Hide window (keep buffer running, saves current size)
require('flex_plane').hide(id)
```

### Close

```lua
-- Close specific window (by ID)
require('flex_plane').close(1)

-- Close all windows
require('flex_plane').close_all()
```

### Move Window

```lua
-- Move current window to a position (must be in flex_plane window)
require('flex_plane').move('top')
require('flex_plane').move('bottom')
require('flex_plane').move('left')
require('flex_plane').move('right')
```

**Terminal mode shortcuts** (when focused in a flex_plane terminal):
- `Ctrl-h` - Move window to the left
- `Ctrl-j` - Move window to the bottom
- `Ctrl-k` - Move window to the top
- `Ctrl-l` - Move window to the right

Window size is preserved after moving.

### Quickfix List

```lua
-- Open quickfix list with all windows
require('flex_plane').list()
```

Shows all windows with visibility status and size info. Press `<Enter>` to toggle.

## Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `position` | string | `"right"` | Window position: `"left"`, `"right"`, `"top"`, `"bottom"` |
| `default_width` | number\|function | `80` | Default width for vertical splits |
| `default_height` | number\|function | `20` | Default height for horizontal splits |
| `default_cmd` | string | `vim.o.shell` | Default command to run |
| `close_on_exit` | boolean | `false` | Auto-close window when command exits |

## Window Size Persistence

Windows automatically remember their size:
1. When you manually resize a window (with mouse or `Ctrl-w >/</+/-`), the size is saved
2. When you toggle/show the window again, it restores to your saved size
3. Windows are protected from other plugins (using `winfixwidth`/`winfixheight`)

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

vim.keymap.set('n', '<leader>tl', function()
  require('flex_plane').list()
end, { desc = 'List all windows (quickfix)' })
```
