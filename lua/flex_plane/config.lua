local M = {}

---@class FlexPlaneConfig
---@field direction "vertical"|"horizontal" Split direction
---@field split_cmd string Split command (e.g., "botright", "topleft", "")
---@field default_width number|function Default width for vertical splits
---@field default_height number|function Default height for horizontal splits
---@field default_cmd string Default command to run
---@field close_on_exit boolean Close window when command exits

M.options = {
  direction = "vertical",
  split_cmd = "botright",
  default_width = 80,
  default_height = 20,
  default_cmd = vim.o.shell,
  close_on_exit = false,
}

--- Setup plugin configuration
---@param opts table?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
