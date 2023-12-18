---@class BufferStack
---@field buffers integer[]
local M = {}

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
  if #M.buffers <= 1 then
    return
  end

  vim.api.nvim_set_current_buf(M.buffers[#M.buffers])
  local cur_buffer = M.buffers[1]

  for i = 1, #M.buffers - 1 do
    M.buffers[i] = M.buffers[i + 1]
  end

  M.buffers[#M.buffers] = cur_buffer
end

function M.bprevious()
  if #M.buffers <= 1 then
    return
  end

  vim.api.nvim_set_current_buf(M.buffers[2])
  local new_buffers = {}
  new_buffers[1] = M.buffers[#M.buffers]

  for i = 1, #M.buffers - 1 do
    new_buffers[i + 1] = M.buffers[i]
  end

  M.buffers = new_buffers
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
