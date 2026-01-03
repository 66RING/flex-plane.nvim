local config = require("flex_plane.config")
local M = {}

---@class FlexPlaneWindow
---@field id number
---@field buf number
---@field win number
---@field cmd string
---@field opts table

---@type FlexPlaneWindow[]
M.windows = {}

--- Create a new flex plane window
---@param cmd string? Command to run (optional, uses default if not provided)
---@param user_opts table? User options
---@return number win_id
function M.open(cmd, user_opts)
  local opts = vim.tbl_deep_extend("force", config.options, user_opts or {})

  -- Calculate window size
  local width = opts.width
  if type(width) == "function" then
    width = width()
  end

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  local buf_name = cmd and ("flex-plane: " .. cmd) or "flex-plane: terminal"
  vim.api.nvim_buf_set_name(buf, buf_name)

  -- Calculate window position and size
  local col = opts.position == "left" and 0 or vim.o.columns - width
  local row = 0

  -- Open window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = vim.o.lines,
    row = row,
    col = col,
    style = "minimal",
    border = opts.border,
  })

  -- Set window options
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "signcolumn", "no")

  -- Store window info
  local window_info = {
    id = #M.windows + 1,
    buf = buf,
    win = win,
    cmd = cmd or opts.default_cmd,
    opts = opts,
  }
  table.insert(M.windows, window_info)

  -- Run command
  if window_info.cmd then
    M.run_command(window_info)
  end

  -- Set up autoclose
  if opts.close_on_exit then
    vim.api.nvim_buf_attach(buf, false, {
      on_detach = function()
        M.close(window_info.id)
      end,
    })
  end

  return window_info.id
end

--- Run command in window
---@param window_info FlexPlaneWindow
function M.run_command(window_info)
  local cmd = window_info.cmd
  local buf = window_info.buf

  if not cmd or cmd == "" then
    return
  end

  -- Check if it's a terminal command (starts with term)
  local is_terminal = vim.startswith(cmd, "term:") or
    vim.startswith(cmd, "terminal:") or
    vim.startswith(cmd, "!")

  local final_cmd = cmd:gsub("^term:", ""):gsub("^terminal:", ""):gsub("^!", "")

  -- Open terminal in buffer
  vim.fn.termopen(final_cmd, {
    on_exit = function(_, exit_code, _)
      if window_info.opts.close_on_exit then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            M.close(window_info.id)
          end
        end)
      end
    end,
  })

  -- Enter insert mode
  vim.cmd("startinsert")
end

--- Close a flex plane window
---@param id number Window ID
function M.close(id)
  for i, win_info in ipairs(M.windows) do
    if win_info.id == id then
      if vim.api.nvim_win_is_valid(win_info.win) then
        vim.api.nvim_win_close(win_info.win, true)
      end
      if vim.api.nvim_buf_is_valid(win_info.buf) then
        vim.api.nvim_buf_delete(win_info.buf, { force = true })
      end
      table.remove(M.windows, i)
      return true
    end
  end
  return false
end

--- Close all flex plane windows
function M.close_all()
  for i = #M.windows, 1, -1 do
    M.close(M.windows[i].id)
  end
end

--- Toggle a flex plane window
---@param cmd string? Command to run
---@param user_opts table? User options
function M.toggle(cmd, user_opts)
  -- Find existing window with same command
  for _, win_info in ipairs(M.windows) do
    if win_info.cmd == (cmd or config.options.default_cmd) then
      M.close(win_info.id)
      return
    end
  end
  M.open(cmd, user_opts)
end

--- Setup plugin options
---@param opts table?
function M.setup(opts)
  config.setup(opts)
end

function M.hi()
  print("i")
end

return M
