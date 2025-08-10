if vim.g.loaded_vim_extras then
  return
end
vim.g.loaded_vim_extras = true
local extras = require("extras")

-- general utilities {{{

-- roots {{{

vim.g["extras#get_root"] = function(cmd, dir)
  if dir == nil then return vim.g.systemlist(cmd)[1] end
  return vim.fn.systemlist('cd '..dir..' && '..cmd)[1]
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
    'direnv status | '.."sed -En 's#Found RC path (.*)/[^/]*#\\1#p'",
    dir
  )
  if root == '' then error('Not in direnv environment') end
  return root
end

--  }}}

-- comand helpers {{{

vim.g["extras#count_on_function"] = function(fn, arg, name)
  local name = name
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

-- TODO visual selection

--  }}}

-- commands {{{

vim.api.nvim_create_user_command(
  "TabOpen", function(opts)
    local count = opts.count
    if count == 0 then count = -1 end
    vim.cmd(opts.count .. "tabnew")
    local files = vim.fn.split(
      opts.args,
      -- just in case (Tm)
      "\\v(^|[^\\\\])(\\\\+)\\2\\zs |[^\\\\]\\zs "
      -- TODO would this be enough
      -- "[^\\\\]\\zs "
    )
    vim.cmd.arglocal({
      bang = true,
      args = files,
    })
  end, { complete = "file", nargs = "*", count = 1 }
)

vim.api.nvim_create_user_command(
  "BDelete", function(opts)
    vim.fn["extras#command_on_expanded"]("bdelete", opts.fargs)
  end, { complete = "buffer", nargs = "*" }
)

vim.api.nvim_create_user_command(
  "BWipeout", function(opts)
    vim.fn["extras#command_on_expanded"]("bwipeout", opts.fargs)
  end, { complete = "buffer", nargs = "*" }
)

vim.api.nvim_create_user_command(
  "BAdd", function(opts)
    vim.fn["extras#command_on_expanded"]("badd", opts.fargs)
  end, { complete = "buffer", nargs = "*" }
)

--  }}}
