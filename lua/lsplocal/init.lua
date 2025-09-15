local M = {}

--- Merges a user-provided configuration table with the existing LSP server configuration. It checks
--- for an existing manager object or the base configuration and performs a deep merge, then calls
--- the server's setup function with the new configuration.
---
---@param server string The name of the LSP server (e.g., "lua_ls").
---@param extra table A table containing the extra configuration to be merged.
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

return M
