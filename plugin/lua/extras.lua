if vim.g.loaded_vim_extras then
  return
end
vim.g.loaded_vim_extras = true
local extras = require("extras")

-- general utilities {{{

vim.fn["extras#count_on_command"] = function(fn, arg)
  return function() for _ = 1, vim.v.count1 do fn(arg) end end
end

vim.fn["extras#get_netrw_fp"] = function()
  return vim.b.netrw_curdir .. "/" .. vim.fn["netrw#Call"]("NetrwGetWord")
end

vim.fn["extras#command_on_expanded"] = function(command, args)
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

-- vim functions {{{

-- small helper for quicker (?) going several directories up
vim.g.B = function(n)
  if n == nil then
    n = 1
  end
  return extras.repeat_str("../", n - 1) .. ".."
end

--  }}}
