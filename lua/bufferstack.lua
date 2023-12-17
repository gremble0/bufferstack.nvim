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
  local next_buffer = M.buffers[#M.buffers]
  local new_buffers = { next_buffer }
  vim.api.nvim_set_current_buf(next_buffer)

  for i = 1, #M.buffers do
    new_buffers[i + 1] = M.buffers[i]
  end

  M.buffers = new_buffers
end

function M.bprevious()
  --TODO FIX
  local previous_buffer = M.buffers[2]
  if previous_buffer == nil then return end
  local new_buffers = { previous_buffer }
  vim.api.nvim_set_current_buf(previous_buffer)

  for i = 2, #M.buffers do
    new_buffers[i] = M.buffers[i]
  end

  new_buffers[#new_buffers + 1] = M.buffers[1]

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
