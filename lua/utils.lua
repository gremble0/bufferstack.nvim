local M = {}

---Shifts all elements in the given list one step to the left,
---leftmost element goes to the back
---@param list any[]
---@return any[]
function M.shift_left(list)
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
function M.shift_right(list)
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

return M
