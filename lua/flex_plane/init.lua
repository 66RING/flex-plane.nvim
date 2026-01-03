local config = require("flex_plane.config")
local M = {}

---@class FlexPlaneWindow
---@field id number
---@field buf number
---@field cmd string
---@field desc string? Description for the window
---@field opts table
---@field width number? Saved width for vertical splits
---@field height number? Saved height for horizontal splits

---@type FlexPlaneWindow[]
M.windows = {}

local augroup = vim.api.nvim_create_augroup("FlexPlane", { clear = true })

--- Convert direction to split command
---@param direction string
---@return string split_cmd, boolean is_vertical
local function direction_to_split(direction)
  if direction == "left" then
    return "topleft vsplit", true
  elseif direction == "right" then
    return "botright vsplit", true
  elseif direction == "top" then
    return "topleft split", false
  elseif direction == "bottom" then
    return "botright split", false
  end
  -- Fallback for old config values
  if direction == "vertical" then
    return "vsplit", true
  elseif direction == "horizontal" then
    return "split", false
  end
  return "vsplit", true
end

--- Save window size when user resizes it
---@param win_info FlexPlaneWindow
local function save_window_size(win_info)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == win_info.buf then
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)
      win_info.width = width
      win_info.height = height
      break
    end
  end
end

--- Apply saved size to window
---@param win_info FlexPlaneWindow
---@param win number Window handle
local function apply_window_size(win_info, win)
  local opts = win_info.opts

  -- Set winfix options to prevent other plugins from resizing
  vim.api.nvim_set_option_value("winfixwidth", true, { win = win })
  vim.api.nvim_set_option_value("winfixheight", true, { win = win })

  local split_cmd, is_vertical = direction_to_split(opts.position)

  if is_vertical then
    if win_info.width then
      vim.api.nvim_win_set_width(win, win_info.width)
    elseif opts.default_width then
      local width = type(opts.default_width) == "function" and opts.default_width() or opts.default_width
      vim.api.nvim_win_set_width(win, width)
      win_info.width = width
    end
  else -- horizontal
    if win_info.height then
      vim.api.nvim_win_set_height(win, win_info.height)
    elseif opts.default_height then
      local height = type(opts.default_height) == "function" and opts.default_height() or opts.default_height
      vim.api.nvim_win_set_height(win, height)
      win_info.height = height
    end
  end
end

--- Create a new flex plane window
---@param cmd string? Command to run (optional, uses default if not provided)
---@param user_opts table? User options (can include `desc` field for description)
---@return number buf_id Buffer ID
function M.open(cmd, user_opts)
  local opts = vim.tbl_deep_extend("force", config.options, user_opts or {})
  local desc = opts.desc or cmd or "terminal"

  -- Check if window with same command and desc already exists
  for _, win_info in ipairs(M.windows) do
    if win_info.cmd == (cmd or opts.default_cmd) and win_info.desc == desc then
      -- Check if buffer still valid
      if not vim.api.nvim_buf_is_valid(win_info.buf) then
        -- Buffer invalid, remove and create new
        table.remove(M.windows, win_info.id)
        break
      end

      -- Check if window is visible
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == win_info.buf then
          vim.api.nvim_set_current_win(win)
          return win_info.buf
        end
      end

      -- Window not visible, show it
      M.show(win_info.id)
      return win_info.buf
    end
  end

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  local buf_name = string.format("flex-plane: %s", desc)
  vim.api.nvim_buf_set_name(buf, buf_name)

  -- Store window info
  local window_info = {
    id = #M.windows + 1,
    buf = buf,
    cmd = cmd or opts.default_cmd,
    desc = desc,
    opts = opts,
    width = nil,
    height = nil,
  }
  table.insert(M.windows, window_info)

  -- Open split window
  local split_cmd = direction_to_split(opts.position)
  vim.cmd(split_cmd)

  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  -- Apply window size
  apply_window_size(window_info, win)

  -- Run command
  if window_info.cmd then
    M.run_command(window_info)
  end

  return window_info.buf
end

--- Run command in window
---@param window_info FlexPlaneWindow
function M.run_command(window_info)
  local cmd = window_info.cmd
  local buf = window_info.buf

  if not cmd or cmd == "" then
    return
  end

  local final_cmd = cmd:gsub("^term:", ""):gsub("^terminal:", ""):gsub("^!", "")

  -- Open terminal in buffer
  vim.fn.termopen(final_cmd)

  -- Enter insert mode
  vim.cmd("startinsert")
end

--- Close a flex plane window
---@param id number Window ID
function M.close(id)
  for i, win_info in ipairs(M.windows) do
    if win_info.id == id then
      -- Close all windows showing this buffer
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == win_info.buf then
          vim.api.nvim_win_close(win, true)
        end
      end
      -- Delete buffer
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
---@param user_opts table? User options (can include `desc` field for description)
function M.toggle(cmd, user_opts)
  local opts = vim.tbl_deep_extend("force", config.options, user_opts or {})
  local desc = opts.desc or cmd or "terminal"

  -- Find existing window with same command and desc
  for _, win_info in ipairs(M.windows) do
    if win_info.cmd == (cmd or config.options.default_cmd) and win_info.desc == desc then
      -- Check if buffer still valid
      if not vim.api.nvim_buf_is_valid(win_info.buf) then
        -- Buffer invalid, remove and create new
        table.remove(M.windows, win_info.id)
        break
      end

      -- Check if window is visible
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == win_info.buf then
          -- Window is visible, hide it
          M.hide(win_info.id)
          return
        end
      end
      -- Buffer exists but not visible, show it
      M.show(win_info.id)
      return
    end
  end
  M.open(cmd, user_opts)
end

--- Show an existing flex plane window (open in split)
---@param id number Window ID
function M.show(id)
  for _, win_info in ipairs(M.windows) do
    if win_info.id == id then
      local opts = win_info.opts
      local split_cmd = direction_to_split(opts.position)
      vim.cmd(split_cmd)

      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, win_info.buf)

      -- Restore saved size
      apply_window_size(win_info, win)
      return true
    end
  end
  return false
end

--- Hide a flex plane window (close window but keep buffer)
---@param id number Window ID
function M.hide(id)
  for _, win_info in ipairs(M.windows) do
    if win_info.id == id then
      -- Save size before hiding
      save_window_size(win_info)

      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == win_info.buf then
          vim.api.nvim_win_close(win, true)
        end
      end
      return true
    end
  end
  return false
end

--- Get the flex plane window info for current window
---@return FlexPlaneWindow?
local function get_current_flex_plane_window()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, win_info in ipairs(M.windows) do
    if win_info.buf == current_buf then
      return win_info
    end
  end
  return nil
end

--- Move current flex plane window to a direction
---@param direction "top"|"bottom"|"left"|"right"
function M.move(direction)
  local win_info = get_current_flex_plane_window()
  if not win_info then
    vim.notify("Not in a flex plane window", vim.log.levels.WARN)
    return
  end

  -- Save original position
  local original_position = win_info.opts.position

  -- Temporarily change position
  win_info.opts.position = direction

  -- Close current window (keeps buffer)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == win_info.buf then
      vim.api.nvim_win_close(win, true)
      break
    end
  end

  -- Reopen at new position
  local split_cmd = direction_to_split(direction)
  vim.cmd(split_cmd)

  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, win_info.buf)

  -- Clear saved size and apply defaults
  win_info.width = nil
  win_info.height = nil
  apply_window_size(win_info, new_win)
end

--- List all flex plane windows in quickfix
function M.list()
  if #M.windows == 0 then
    vim.notify("No flex plane windows", vim.log.levels.INFO)
    return
  end

  local qf_list = {}
  for idx, win_info in ipairs(M.windows) do
    local visible = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == win_info.buf then
        visible = true
        break
      end
    end

    local status = visible and "+" or " "
    local size_info = ""
    local _, is_vertical = direction_to_split(win_info.opts.position)
    if is_vertical and win_info.width then
      size_info = string.format("[%d cols] ", win_info.width)
    elseif not is_vertical and win_info.height then
      size_info = string.format("[%d rows] ", win_info.height)
    end

    local display_desc = win_info.desc or win_info.cmd
    table.insert(qf_list, {
      bufnr = 0,
      lnum = idx,
      col = 1,
      text = string.format("[%s] %s%s", status, size_info, display_desc),
    })
  end

  -- Store mapping from line number to window info
  M._qf_windows = {}
  for idx, win_info in ipairs(M.windows) do
    M._qf_windows[idx] = win_info
  end

  vim.fn.setqflist(qf_list, "r")
  vim.cmd("copen")

  -- Map Enter to toggle
  local qf_win = vim.fn.win_getid(vim.fn.winnr("$"))
  local qf_buf = vim.api.nvim_win_get_buf(qf_win)
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local win_info = M._qf_windows[line]
    if win_info then
      vim.cmd("cclose")
      M.toggle(win_info.cmd, { desc = win_info.desc })
    end
  end, { buffer = qf_buf, nowait = true })
end

--- Setup plugin options
---@param opts table?
function M.setup(opts)
  config.setup(opts)

  -- Set up WinResized autocmd to track user window size changes
  vim.api.nvim_create_autocmd("WinResized", {
    group = augroup,
    callback = function()
      for _, win_info in ipairs(M.windows) do
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == win_info.buf then
            if vim.tbl_contains(vim.v.event.windows, win) then
              -- User resized this window, save the new size
              save_window_size(win_info)
            end
          end
        end
      end
    end,
  })
end

return M
