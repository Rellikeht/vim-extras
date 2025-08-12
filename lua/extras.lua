local function shallow_copy(value)
  if type(value) ~= "table" then
    return value
  end
  local result = {}
  for k, v in pairs(value) do result[k] = v end
  return result
end

local function deep_copy(value)
  if type(value) ~= "table" then
    return value
  end
  local result = {}
  for k, v in pairs(value) do
    result[deep_copy(k)] = deep_copy(v)
  end
  return result
end

local function table_join(t1, t2)
  for k, v in pairs(t2) do
    table.insert(t1, k, v)
  end
end

local function string_repeat(str, times)
  local result = ""
  for _ = 1, times do
    result = result .. str
  end
  return result
end

local function to_string(value, row)
  local rowstr = string_repeat(" ", row)
  if type(value) ~= "table" then
    return tostring(value)
  end
  return "{\n" ..
      str_recursive_row(value, row + 2) ..
      rowstr ..
      "}"
end

local function row_to_string(table, row)
  local result = ""
  for k, v in pairs(table) do
    result = result ..
        string_repeat(" ", row) ..
        to_string(k, row) ..
        " : " ..
        to_string(v, row) ..
        "\n"
  end
  return result
end

local function print_recursive(table)
  print(row_to_string(table, 0))
end

local function map(func, table)
  local result = {}
  for k, v in pairs(table) do
    result[k] = func(v)
  end
  return result
end

local function equal_recursive(t1, t2)
  if #t1 ~= #t2 then
    return false
  end
  if type(t1) ~= "table" then
    if type(t1) ~= type(t2) or t1 ~= t2 then
      return false
    end
  end
  for k, v in pairs(t1) do
    if not equal_recursive(t1[k], t2[k]) then
      return false
    end
  end
end

local function table_find(tbl, value)
  for k, elem in pairs(tbl) do
    if equal_recursive(elem, value) then
      return k
    end
  end
  return nil
end

local M = { --  {{{
  shallow_copy = shallow_copy,
  deep_copy = deep_copy,
  string_repeat = string_repeat,
  print_recursive = print_recursive,
  equal_recursive = equal_recursive,
  table_join = table_join,
  table_find = table_find,
  map = map,
} --  }}}

return M
