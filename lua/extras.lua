local function shallow_copy_table(tbl)
  local result = {}
  for k, v in pairs(tbl) do result[k] = v end
  return result
end

local function deep_copy_table(tbl)
  -- TODO
end

local function join_tables(t1, t2)
  for k, v in pairs(t2) do
    table.insert(t1, k, v)
  end
end

local function repeat_str(str, times)
  local result = ""
  for _ = 1, times do
    result = result .. str
  end
  return result
end

local function str_value(value, row)
  local rowstr = repeat_str(" ", row)
  if type(value) ~= "table" then
    return tostring(value)
  end
  return "{\n" ..
      str_recursive_row(value, row + 2) ..
      rowstr ..
      "}"
end

local function str_recursive_row(table, row)
  local result = ""
  for k, v in pairs(table) do
    result = result ..
        repeat_str(" ", row) ..
        str_value(k, row) ..
        " : " ..
        str_value(v, row) ..
        "\n"
  end
  return result
end

local function print_recursive(table)
  print(str_recursive_row(table, 0))
end

local function map(func, table)
  local result = {}
  for k, v in pairs(table) do
    result[k] = func(v)
  end
  return result
end

local M = { --  {{{
  shallow_copy_table = shallow_copy_table,
  deep_copy_table = deep_copy_table,
  join_tables = join_tables,
  repeat_str = repeat_str,
  print_recursive = print_recursive,
  map = map,
} --  }}}

return M
