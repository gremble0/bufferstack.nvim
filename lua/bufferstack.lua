---@class BufferStack
---@field buffers integer[]
local M = {}

local function shift_left(list)
    local firstElement = list[1]

    for i = 1, #list - 1 do
        list[i] = list[i+1]
    end

    list[#list] = firstElement

    return list
end

local function shift_right(list)
  local out = {}
  local length = #list

  if length == 0 then
    return out
  end

  out[1] = list[length]

  for i = 1, length - 1 do
    out[i + 1] = list[i]
  end

  return out
end


---@param buffer integer
function M.add_buffer(buffer)
  -- TODO: inplace?
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
  M.buffers = buffers
  vim.api.nvim_set_current_buf(M.buffers[1])
  M.buffers = buffers
end

function M.bprevious()
  local buffers = shift_left(M.buffers)
  M.buffers = buffers
  vim.api.nvim_set_current_buf(M.buffers[1])
  M.buffers = buffers
end

function M.show()
  for _, buf in ipairs(M.buffers) do
    local bufname
    if vim.api.nvim_buf_is_loaded(buf) then
      bufname = vim.api.nvim_buf_get_name(buf)
    else
      bufname = "*DELETED*"
    end
    print(buf, bufname)
  end
  print("---------")
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
