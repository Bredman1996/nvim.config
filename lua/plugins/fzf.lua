return {
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>sf", "<cmd>FzfLua files<cr>", desc = "Search Files" },
			{ "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Search Live Grep" },
			{ "<leader>sh", "<cmd>FzfLua helptags<cr>", desc = "Search Help" },
			{ "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Search Document Diagnostics" },
			{ "<leader>sf", "<cmd>FzfLua files<cr>", desc = "Search Files" },
		},
		---@module "fzf-lua"
		---@type fzf-lua.Config|{}
		---@diagnostic disable: missing-fields
		opts = {},
		---@diagnostic enable: missing-fields
	},
}
