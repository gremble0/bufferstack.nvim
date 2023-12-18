---@class BufferStack
---@field buffers integer[]
local M = {}

local function shift_left(list)
  if #list <= 1 then
    return list
  end

  local first = list[1]

  for i = 1, #list - 1 do
      list[i] = list[i + 1]
  end

  list[#list] = first

  return list
end

local function shift_right(list)
  if #list <= 1 then
    return list
  end

  local last = list[#list]

  for i = #list, 2, - 1 do
    list[i] = list[i - 1]
  end

  list[1] = last

  return list
end

---@param buffer integer
function M.add_buffer(buffer)
  local new_buffers = { buffer }

  for i, buf in ipairs(M.buffers) do
    if buf ~= buffer then
      new_buffers[i + 1] = buf
    end
  end

  M.buffers = new_buffers
end

function M.bnext()
  local buffers = shift_right(M.buffers)
  vim.api.nvim_set_current_buf(buffers[1])
  M.buffers = buffers
end

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
    callback = function() M.add_buffer(vim.api.nvim_get_current_buf()) end
  })
end

return M
