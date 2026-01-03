package.loaded['flex_plane'] = nil
package.loaded['flex_plane.config'] = nil
package.loaded['dev'] = nil

vim.cmd[[set rtp+=.]]
vim.api.nvim_set_keymap('n', ',r', ':luafile dev/init.lua<cr>', {})

-- plug = require('flex_plane')

-- vim.api.nvim_set_keymap('n', ',w', ':lua Greetings.greet()<cr>', {})

require('flex_plane').setup({
  width = 80,
  position = 'right',
  border = 'single',
  default_cmd = vim.o.shell,
  close_on_exit = false,
})
