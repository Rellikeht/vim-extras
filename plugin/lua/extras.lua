if vim.g.loaded_vim_extras then
  return
end
vim.g.loaded_vim_extras = true
local extras = require("extras")

-- lua specific utilities {{{

vim.g["extras#escape_qargs"] = function(arg)
  return vim.fn.escape(arg, "<%#")
end

vim.g["extras#split_qargs"] = function(arg)
  -- just in case (Tm)
  -- "\\v(^|[^\\\\])(\\\\+)\\2\\zs |[^\\\\]\\zs "
  -- TODO would this be enough
  return vim.fn.split(vim.g["extras#escape_qargs"](arg), "[^\\]\\zs ")
end

--  }}}

-- general utils {{{

-- TODO visual selection

--  }}}

-- roots {{{

vim.g["extras#get_root"] = function(cmd, dir)
  if dir == nil then return vim.g.systemlist(cmd)[1] end
  return vim.fn.systemlist('cd ' .. dir .. ' && ' .. cmd)[1]
end

vim.g["extras#git_root"] = function(dir)
  if dir == nil then dir = "" end
  return vim.g["extras#get_root"]('git rev-parse --show-toplevel', dir)
end

vim.g["extras#hg_root"] = function(dir)
  if dir == nil then dir = "" end
  return vim.g["extras#get_root"]('hg root', dir)
end

vim.g["extras#part_root"] = function(dir)
  if dir == nil then dir = "" end
  return vim.g["extras#get_root"]("df -P . | awk '/^\\// {print $6}'", dir)
end

vim.g["extras#envrc_root"] = function(dir)
  if dir == nil then dir = "" end
  local root = vim.g["extras#get_root"](
    'direnv status | ' .. "sed -En 's#Found RC path (.*)/[^/]*#\\1#p'",
    dir
  )
  if root == '' then error('Not in direnv environment') end
  return root
end

--  }}}

-- completion utils {{{

vim.g["extras#list_completion_builder"] = function(list, lead, cmdline, curpos)
  -- TODO
end

vim.g["extras#list_completion"] = function(list)
  return function(lead, cmdline, curpos)
    vim.g["extras#list_completion_builder"](list, lead, cmdline, curpos)
  end
end

vim.g["extras#args_complete"] = function(lead, cmdline, cursorpos)
  -- Completes files from arglist
  local completions = vim.fn.getcompletion(lead, "arglist")
  return extras.map(vim.fn.fnameescape, completions)
end

--  }}}

-- comand helpers {{{

vim.g["extras#count_on_function"] = function(fn, arg, name)
  if name == nil then
    name = "count1"
  end
  return function() for _ = 1, vim.v[name] do fn(arg) end end
end

vim.g["extras#get_netrw_fp"] = function()
  return vim.b.netrw_curdir .. "/" .. vim.fn["netrw#Call"]("NetrwGetWord")
end

vim.g["extras#command_on_expanded"] = function(command, args)
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

-- small helper for quicker (?) going several directories up
vim.g.B = function(n)
  if n == nil then
    n = 1
  end
  return extras.repeat_str("../", n - 1) .. ".."
end

--  }}}

-- commands {{{

-- helpers {{{

local function tabopen_helper(opts)
  local pos = opts.count
  if opts.range == 0 then
    pos = vim.fn.tabpagenr()
  end
  vim.cmd(pos .. "tabnew")
  vim.cmd("arglocal " .. vim.g["extras#escape_qargs"](opts.args))
end

local function user_command_helper(command, opts)
  vim.g["extras#command_on_expanded"](
    command,
    vim.g["extras#split_qargs"](opts.args)
  )
end

--  }}}

--  {{{

vim.api.nvim_create_user_command(
  "TabOpen", tabopen_helper, {
    complete = "file",
    nargs = "*",
    range = 1,
    addr = "tabs",
  }
)

vim.api.nvim_create_user_command(
  "TabOpenBuf", tabopen_helper, {
    complete = "buffer",
    nargs = "*",
    range = 1,
    addr = "tabs",
  }
)

vim.api.nvim_create_user_command(
  "TabOpenArgs",
  tabopen_helper, {
    complete = vim.g["extras#args_complete"],
    nargs = "*",
    range = 1,
    addr = "tabs",
  }
)

vim.api.nvim_create_user_command(
  "BDelete",
  function(opts) user_command_helper("bdelete", opts) end,
  { complete = "buffer", nargs = "*" }
)

vim.api.nvim_create_user_command(
  "BWipeout",
  function(opts) user_command_helper("bwipeout", opts) end,
  { complete = "buffer", nargs = "*" }
)

vim.api.nvim_create_user_command(
  "BAdd",
  function(opts) user_command_helper("badd", opts) end,
  { complete = "file", nargs = "*" }
)

--  }}}

-- different completion versions {{{

-- TODO

-- }}}

-- other {{{

vim.api.nvim_create_user_command(
  "SetOptionCount",
  function(args)
    local val = vim.v.count
    if val == 0 then
      val = args.count
    end
    vim.o[args.args] = val
  end,
  { nargs = 1, count = 1, complete = "option" }
)

--  }}}

--  }}}
