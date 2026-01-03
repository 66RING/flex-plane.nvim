local M = {}

---@class FlexPlaneConfig
---@field position "left"|"right"|"top"|"bottom" Window position
---@field default_width number|function Default width for vertical splits
---@field default_height number|function Default height for horizontal splits
---@field default_cmd string Default command to run

M.options = {
  position = "right",
  default_width = 30,
  default_height = 15,
  default_cmd = vim.o.shell,
}

--- Setup plugin configuration
---@param opts table?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
