---@class BufferStack
---@field buffers integer[]
local M = {}

---Shifts all elements in the given list one step to the left,
---leftmost element goes to the back
---@param list any[]
---@return any[]
local function shift_left(list)
  if #list <= 1 then
    return list
  end

  local first = list[1]

  for i = 1, #list -1 do
      list[i] = list[i + 1]
  end

  list[#list] = first

  return list
end

---Shifts all elements in the given list one step to the right,
---rightmost element goes to the front
---@param list any[]
---@return any[]
local function shift_right(list)
  if #list <= 1 then
    return list
  end

  local last = list[#list]

  for i = #list, 2, -1 do
    list[i] = list[i - 1]
  end

  list[1] = last

  return list
end

---Adds the buffer to the front of the internal stack of open buffers
---@param buffer integer
function M.push_front(buffer)
  local new_buffers = { buffer }

  for i, buf in ipairs(M.buffers) do
    if buf ~= buffer then
      new_buffers[i + 1] = buf
    end
  end

  M.buffers = new_buffers
end

---Updates the internal stack of buffers by shifting it to the right
---and sets the current buffer to the new element at the front
function M.bnext()
  local buffers = shift_right(M.buffers)
  vim.api.nvim_set_current_buf(buffers[1])
  M.buffers = buffers
end

---Updates the internal stack of buffers by shifting it to the left
---and sets the current buffer to the new element at the front
function M.bprevious()
  local buffers = shift_left(M.buffers)
  vim.api.nvim_set_current_buf(buffers[1])
  M.buffers = buffers
end

function M.setup()
  M.buffers = {}

  local buffer_stack_group = vim.api.nvim_create_augroup("BufferStack", {})
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = buffer_stack_group,
    callback = function() M.push_front(vim.api.nvim_get_current_buf()) end
  })
end

return M
