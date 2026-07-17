return {
	"bredman1996/web-search.nvim",
	--	dir = "~/source/web-search.nvim",
	config = function()
		local os = string.lower(vim.loop.os_uname().sysname)
		local browserCommand = "xdg-open"

		if os == "darwin" then
			browserCommand = "open"
		elseif os == "windows_nt" then
			browserCommand = "start"
		end

		require("web-search").setup({
			sourceMaps = {
				-- { name = "", source = "" },
				{ name = "harness", source = "harness/harness" },
				{ name = "cloudflare", source = "cloudflare/cloudflare" },
			},
			searchEngine = "duckduckgo",
			browserCommand = browserCommand,
		})
		vim.keymap.set("n", "<leader>wS", "<cmd>WebSearch<CR>", { desc = "WebSearch Prompt" })
		vim.keymap.set("v", "<leader>wS", "<cmd>WebSearchSelection<CR>", { desc = "WebSearch Search Highlighted" })
		vim.keymap.set("v", "<leader>wt", "<cmd>WebSearchTerraform<CR>", { desc = "WebSearch Search Terraform" })
		vim.keymap.set("v", "<leader>wa", "<cmd>WebSearchAdo<CR>", { desc = "WebSearch Search AzureDevops Tasks" })
	end,
}
