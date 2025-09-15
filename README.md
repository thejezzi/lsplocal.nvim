# lsplocal.nvim

**DISCLAIMER**: This plugin relies on exrc, which may pose security risks as it can execute code
from an `.exrc` or `.nvimrc` file in the current working directory. Use with caution and review such
files in your project directory before enabling exrc.

A small Neovim utility to merge local configurations with existing LSP server setups.

## Purpose

This plugin provides a single function, `configure`, which allows you to programmatically extend the
configuration of an already configured LSP server from `nvim-lspconfig`.

It's useful for dynamically changing settings based on project-specific needs (e.g., in `.vim.lua`
or `.nvim.lua` files) without duplicating your entire LSP setup.

## Installation

Install with your favorite plugin manager.

### lazy.nvim

```lua
{ "your-username/lsplocal.nvim" }
```

### Packer

```lua
use { "your-username/lsplocal.nvim" }
```

## Usage

After your main LSP configurations have been loaded, you can call the function to merge additional
settings.

For example, imagine your `init.lua` sets up `lua_ls` like this:

```lua
require('lspconfig').lua_ls.setup({})
```

Now, in a project-specific file (e.g., `~/projects/my-project/.nvim.lua`), you can add settings just
for that project:

> **Note:** The following example assumes you have enabled `exrc` in Neovim and that your
> `.nvim.lua` file is sourced when you open Neovim in the project directory. You can check if `exrc`
> is enabled by running `:set exrc?` in Neovim. For more information, see `:help exrc`.

```lua
-- This will be executed when you open nvim in this project's root.
-- It merges the new settings into the existing lua_ls configuration.

require('lsplocal').configure('lua_ls', {
  settings = {
    Lua = {
      workspace = {
        library = {
          '${3rd}/busted/library',
        },
      },
    },
  },
})

```

Or, if you prefer not to use a plugin, you can copy the original function to your `.nvim.lua` file.
This way, you can see exactly what is happening and do not have to fear malicious code in your
config. Note that by doing this, you lose the ability to receive updates or bug fixes from the
plugin automatically.

```lua
M.configure = function(server, extra)
  local lspconfig = require("lspconfig")

  local ok, srv = pcall(function()
    return lspconfig[server]
  end)

  if not ok or not srv then
    vim.notify("LSP server '" .. server .. "' not found", vim.log.levels.WARN)
    return
  end

  local base_config
  if srv.manager and srv.manager.config then
    base_config = srv.manager.config
  else
    vim.notify("No active config for '" .. server .. "', using default_config", vim.log.levels.WARN)
    base_config = srv.document_config.default_config
  end

  local merged_config = vim.tbl_deep_extend("force", {}, base_config, extra or {})
  srv.setup(merged_config)
end
```
