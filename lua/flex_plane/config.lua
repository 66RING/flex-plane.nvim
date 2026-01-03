local M = {}

---@class FlexPlaneConfig
---@field width number|function Window width (columns or function returning number)
---@field position "left"|"right" Window position
---@field border string|table Border style
---@field default_cmd string Default command to run
---@field close_on_exit boolean Close window when command exits

M.options = {
  width = 80,
  position = "right",
  border = "single",
  default_cmd = vim.o.shell,
  close_on_exit = false,
}

--- Setup plugin configuration
---@param opts table?
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
