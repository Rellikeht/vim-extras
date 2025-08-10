if vim.g.loaded_vim_extras then
  return
end
vim.g.loaded_vim_extras = true

-- lua specific utilities {{{

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

--  }}}

-- general utilities {{{

local function count_on_command(fn, arg)
  return function() for _ = 1, vim.v.count1 do fn(arg) end end
end

local function get_netrw_fp()
  return vim.b.netrw_curdir .. "/" .. vim.fn["netrw#Call"]("NetrwGetWord")
end

local function command_on_expanded(command, args)
  local visited = {}
  for _, arg in pairs(args) do
    for _, file in pairs(vim.fn.split(vim.fn.expand(arg), "\n")) do
      if visited[file] == nil then
        vim.cmd[command](vim.fn.fnameescape(file))
        visited[file] = true
      end
    end
  end
end

-- TODO visual selection

--  }}}

-- commands {{{

vim.api.nvim_create_user_command(
  "TabOpen", function(opts)
    local count = opts.count
    if count == 0 then count = -1 end
    vim.cmd(opts.count .. "tabnew")
    vim.cmd("arglocal! " .. opts.args)
  end, { complete = "file", nargs = "*", count = 1 }
)

vim.api.nvim_create_user_command(
  "BDelete", function(opts)
    command_on_expanded("bdelete", opts.fargs)
  end, { complete = "buffer", nargs = "*" }
)

vim.api.nvim_create_user_command(
  "BWipeout", function(opts)
    command_on_expanded("bwipeout", opts.fargs)
  end, { complete = "buffer", nargs = "*" }
)

vim.api.nvim_create_user_command(
  "BAdd", function(opts)
    command_on_expanded("badd", opts.fargs)
  end, { complete = "buffer", nargs = "*" }
)

--  }}}

-- vim functions {{{

vim.g.B = function(n)
  if n == nil then
    n = 1
  end
  return repeat_str("../", n - 1) .. ".."
end

--  }}}

local M = { --  {{{
  -- lua
  shallow_copy_table = shallow_copy_table,
  deep_copy_table = deep_copy_table,
  join_tables = join_tables,
  print_recursive = print_recursive,
  map = map,

  -- general
  count_on_command = count_on_command,
  get_netrw_fp = get_netrw_fp,
  command_on_expanded = command_on_expanded,
} --  }}}

return M
