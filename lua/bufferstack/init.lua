local utils = require("bufferstack.utils")

---@class BufferStack
---@field buffers integer[]
local M = {}

---Updates the internal stack of buffers by shifting it to the right
---and sets the current buffer to the new element at the front
function M.bnext()
  M.buffers = vim.tbl_filter(vim.api.nvim_buf_is_valid, M.buffers)
  M.buffers = utils.shift_left(M.buffers)
  vim.api.nvim_set_current_buf(M.buffers[#M.buffers])
end

---Updates the internal stack of buffers by shifting it to the left
---and sets the current buffer to the new element at the front
function M.bprevious()
  M.buffers = vim.tbl_filter(vim.api.nvim_buf_is_valid, M.buffers)
  M.buffers = utils.shift_right(M.buffers)
  vim.api.nvim_set_current_buf(M.buffers[#M.buffers])
end

---For debugging, prints bufferstack
function M.show()
  print(vim.inspect(M.buffers))
end

---@class BufferStackOpts
---@field bprevious? string keybind to use for the bprevious command
---@field bnext? string keybind to use for the bnext command

---@param opts BufferStackOpts
function M.setup(opts)
  M.buffers = {}

  local buffer_stack_group = vim.api.nvim_create_augroup("BufferStack", {})
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = buffer_stack_group,
    callback = function()
      local cur = vim.api.nvim_get_current_buf()
      if vim.tbl_contains(M.buffers, cur) then
        local i = 0
        for j, buf in ipairs(M.buffers) do
          if buf == cur then
            i = i + 2
          else
            i = i + 1
          end
          M.buffers[j] = M.buffers[i]
        end
      end

      M.buffers[#M.buffers + 1] = cur
    end
  })

  if opts ~= nil then
    -- in case the user only wants one of these functions we make them nullable
    if opts.bprevious ~= nil then
      vim.keymap.set("n", opts.bprevious, M.bprevious, { desc = "Changes to the previous buffer" })
    end
    if opts.bprevious ~= nil then
      vim.keymap.set("n", opts.bnext, M.bnext, { desc = "Changes to the next buffer" })
    end
  end
end

return M
