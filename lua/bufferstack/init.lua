local utils = require("bufferstack.utils")

---@class BufferStack
---@field buffers integer[]
local M = {}

---Deletes buffers that are no longer valid. Ideally would not be necessary
---but there are no autocmds that reliably triggers when we need to remove
---a specific buffer from the stack
function M:sync()
  for i, buf in ipairs(self.buffers) do
    if not vim.api.nvim_buf_is_valid(buf) then
      for j = i, #self.buffers do
        self.buffers[j] = self.buffers[j + 1]
      end
    end
  end
end

---Adds the buffer to the front of the internal stack of open buffers
---@param buffer integer
function M:push_front(buffer)
  local new_buffers = { buffer }

  for i, buf in ipairs(self.buffers) do
    if buf ~= buffer then
      new_buffers[i + 1] = buf
    end
  end

  self.buffers = new_buffers
end

---Updates the internal stack of buffers by shifting it to the right
---and sets the current buffer to the new element at the front
function M.bnext()
  M:sync()
  local buffers = utils.shift_right(M.buffers)
  vim.api.nvim_set_current_buf(buffers[1])
  M.buffers = buffers
end

---Updates the internal stack of buffers by shifting it to the left
---and sets the current buffer to the new element at the front
function M.bprevious()
  M:sync()
  local buffers = utils.shift_left(M.buffers)
  vim.api.nvim_set_current_buf(buffers[1])
  M.buffers = buffers
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
    callback = function() M:push_front(vim.api.nvim_get_current_buf()) end
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