local M = {}

---@class FlexPlaneConfig
---@field position "left"|"right"|"top"|"bottom" Window position
---@field default_width number|function Default width for vertical splits
---@field default_height number|function Default height for horizontal splits
---@field default_cmd string Default command to run
---@field close_on_exit boolean Close window when command exits

M.options = {
  position = "right",
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
