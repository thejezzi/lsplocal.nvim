local M = {}

--- Merges a user-provided configuration table with the existing LSP server configuration. It checks
--- for an existing manager object or the base configuration and performs a deep merge, then calls
--- the server's setup function with the new configuration.
---
---@param server_name string The name of the LSP server (e.g., "lua_ls").
---@param extra table A table containing the extra configuration to be merged.
M.configure = function(server_name, extra)
	local function apply_to(client)
		-- in-place mergen, nicht client.settings ersetzen
		client.settings = client.settings or {}
		if extra and extra.settings then
			for k, v in pairs(extra.settings) do
				client.settings[k] = vim.tbl_deep_extend("force", client.settings[k] or {}, v)
			end
		end

		client:notify("workspace/didChangeConfiguration", {
			settings = client.settings,
		})

		vim.notify(server_name .. " settings updated", vim.log.levels.INFO)
	end

	-- wenn Client schon läuft: sofort anwenden
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == server_name then
			apply_to(client)
		end
	end

	-- ansonsten: beim Attach patchen
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsplocal_config_" .. server_name, { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and client.name == server_name then
				apply_to(client)
			end
		end,
	})
end

return M
