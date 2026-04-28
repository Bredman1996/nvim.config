local snyk_token = os.getenv("SNYK_TOKEN")

return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"mason-org/mason.nvim",
				opts = {
					registries = {
						"github:mason-org/mason-registry",
						"github:Crashdummyy/mason-registry",
					},
				},
			},
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },

			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					vim.bo[event.buf].tabstop = 4
					vim.bo[event.buf].shiftwidth = 4
					vim.bo[event.buf].expandtab = true

					local fzf = require("fzf-lua")
					map("gd", fzf.lsp_definitions, "[G]oto [D]efinition")
					map("gr", fzf.lsp_references, "[G]oto [R]eferences")
					map("gI", fzf.lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", fzf.lsp_typedefs, "Type [D]efinition")
					map("<leader>ds", fzf.lsp_document_symbols, "[D]ocument [S]ymbols")
					map("<leader>ws", fzf.lsp_workspace_symbols, "[W]orkspace [S]ymbols")

					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				clangd = {},
				gopls = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				terraformls = {},
				hclfmt = {},
				powershell_es = {
					filetypes = {
						"ps1",
						"psm1",
						"psd1",
					},
					settings = {
						powershell = {
							codeFormatting = {
								tabSize = 4,
								useTabs = false,
							},
						},
					},
					init_options = {
						enableProfileLoading = false,
					},
				},
				html = {
					filetype = { "html", "htm", "tmpl" },
				},
				yamlls = {
					settings = {
						yaml = {
							format = { enable = true },
							validate = true,
							hover = true,
							schemas = {
								["https://raw.githubusercontent.com/harness/harness-schema/main/v0/template.json"] = {
									".harness/templates/**/*.yaml",
								},
								["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
									"pipelines/*.y*l",
								},
							},
						},
					},
				},
				dockerls = {},
				-- ts_ls = {},
				pylsp = {},
			}

			require("mason-lspconfig").setup({
				automatic_enable = vim.tbl_keys(servers or {}),
			})

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for server_name, config in pairs(servers) do
				vim.lsp.config(server_name, config)
			end
		end,
	},
}
