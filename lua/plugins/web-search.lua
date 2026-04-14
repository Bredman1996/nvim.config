return {
	"bredman1996/web-search.nvim",
	--	dir = "~/source/web-search.nvim",
	config = function()
		require("web-search").setup({
			sourceMaps = {
				-- { name = "", source = "" },
				{ name = "harness", source = "harness/harness" },
				{ name = "cloudflare", source = "cloudflare/cloudflare" },
			},
			searchEngine = "duckduckgo",
		})
		vim.keymap.set("n", "<leader>wS", "<cmd>WebSearch<CR>", { desc = "WebSearch Prompt" })
		vim.keymap.set("v", "<leader>wS", "<cmd>WebSearchSelection<CR>", { desc = "WebSearch Search Highlighted" })
		vim.keymap.set("v", "<leader>wt", "<cmd>WebSearchTerraform<CR>", { desc = "WebSearch Search Terraform" })
		vim.keymap.set("v", "<leader>wa", "<cmd>WebSearchAdo<CR>", { desc = "WebSearch Search AzureDevops Tasks" })
	end,
}
