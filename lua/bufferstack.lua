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

---Deletes buffers that are no longer valid
function M.sync()
  for i, buf in ipairs(M.buffers) do
    if not vim.api.nvim_buf_is_valid(buf) then
      for j = i, #M.buffers do
        M.buffers[j] = M.buffers[j + 1]
      end
    end
  end
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
  M.sync()
  local buffers = shift_right(M.buffers)
  vim.api.nvim_set_current_buf(buffers[1])
  M.buffers = buffers
end

---Updates the internal stack of buffers by shifting it to the left
---and sets the current buffer to the new element at the front
function M.bprevious()
  M.sync()
  local buffers = shift_left(M.buffers)
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
    callback = function() M.push_front(vim.api.nvim_get_current_buf()) end
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
