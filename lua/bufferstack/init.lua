local utils = require("bufferstack.utils")

---@class BufferStack
---@field buffers integer[] stack of open buffers, last index is considered front
---@field filter_buffers_func fun(int): boolean function to use as a predicate to sync the bufferstack
local M = {}

---@param buf integer id of buffer to push onto the stack
---If buf is already in the stack, move buf to the front
function M.push(buf)
  if vim.tbl_contains(M.buffers, buf) then
    local i = 0
    for j, b in ipairs(M.buffers) do
      if b == buf then
        i = i + 2
      else
        i = i + 1
      end
      M.buffers[j] = M.buffers[i]
    end
  end

  M.buffers[#M.buffers + 1] = buf
end

---Updates the internal stack of buffers by shifting it to the right
---and sets the current buffer to the new element at the front
function M.bnext()
  M.buffers = vim.tbl_filter(M.filter_buffers_func, M.buffers)
  M.buffers = utils.shift_left(M.buffers)
  vim.api.nvim_set_current_buf(M.buffers[#M.buffers])
end

---Updates the internal stack of buffers by shifting it to the left
---and sets the current buffer to the new element at the front
function M.bprevious()
  M.buffers = vim.tbl_filter(M.filter_buffers_func, M.buffers)
  M.buffers = utils.shift_right(M.buffers)
  vim.api.nvim_set_current_buf(M.buffers[#M.buffers])
end

---For debugging, prints bufferstack
function M.show()
  M.buffers = vim.tbl_filter(M.filter_buffers_func, M.buffers)
  print(vim.inspect(M.buffers))
end

---@class BufferStackConfig
---@field bprevious? string keybind to use for the bprevious command
---@field bnext? string keybind to use for the bnext command
---@field filter_buffers_func? fun(int): boolean function to use as a predicate to sync the bufferstack

---@type BufferStackConfig
local default_config = {
  filter_buffers_func = vim.api.nvim_buf_is_loaded,
}

---@param opts BufferStackConfig
function M.setup(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, default_config)
  M.buffers = {}

  local buffer_stack_group = vim.api.nvim_create_augroup("BufferStack", {})
  vim.api.nvim_create_autocmd("BufEnter", {
    group = buffer_stack_group,
    callback = function()
      M.push(vim.api.nvim_get_current_buf())
    end
  })

  M.filter_buffers_func = opts.filter_buffers_func
  -- in case the user only wants one of these functions we make them nullable
  if opts.bprevious ~= nil then
    vim.keymap.set("n", opts.bprevious, M.bprevious, { desc = "Changes to the previous buffer" })
  end
  if opts.bnext ~= nil then
    vim.keymap.set("n", opts.bnext, M.bnext, { desc = "Changes to the next buffer" })
  end
end

return M
