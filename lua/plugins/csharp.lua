return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"mason-org/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Mason
			require("mason").setup()

			require("mason-nvim-dap").setup({
				ensure_installed = { "netcoredbg" },
				automatic_installation = true,
			})

			-- Adapter
			dap.adapters.coreclr = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.adapters.netcoredbg = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			local function load_launch_settings()
				local path = vim.fn.getcwd() .. "/Properties/launchSettings.json"
				if vim.fn.filereadable(path) == 0 then
					return {}
				end

				local content = table.concat(vim.fn.readfile(path), "\n")
				local ok, parsed = pcall(vim.json.decode, content)
				if not ok then
					return {}
				end
				return parsed.profiles or {}
			end

			-- Configurations
			dap.configurations.cs = {
				{
					type = "coreclr",
					name = "Launch - netcoredbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
					env = function()
						vim.notify("loading env", vim.log.levels.INFO)
						local profiles = load_launch_settings()
						local profile = profiles[1] or next(profiles)
						return profile and profile.environmentVariables or nil
					end,
					args = function()
						vim.notify("loading args", vim.log.levels.INFO)
						local profiles = load_launch_settings()
						local profile = profiles[1] or next(profiles)
						if profile and profile.commandLineArgs then
							return vim.split(profile.commandLineArgs, " ")
						end
						return {}
					end,
				},
				{
					type = "coreclr",
					name = "Attach to process",
					request = "attach",
					processId = require("dap.utils").pick_process,
					env = function()
						vim.notify("loading env", vim.log.levels.INFO)
						local profiles = load_launch_settings()
						local profile = profiles[1] or next(profiles)
						return profile and profile.environmentVariables or nil
					end,
					args = function()
						vim.notify("loading args", vim.log.levels.INFO)
						local profiles = load_launch_settings()
						local profile = profiles[1] or next(profiles)
						if profile and profile.commandLineArgs then
							return vim.split(profile.commandLineArgs, " ")
						end
						return {}
					end,
				},
			}

			-- UI
			dapui.setup()
			require("nvim-dap-virtual-text").setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Keymaps
			local map = vim.keymap.set
			map("n", "<F5>", function()
				local dap = require("dap")
				if dap.session() then
					dap.continue()
				else
					require("custom.helpers.csharp").build_and_debug()
				end
			end, { desc = "C#: Build/Launch or Continue" })
			map("n", "<F10>", dap.step_over)
			map("n", "<F11>", dap.step_into)
			map("n", "<F12>", dap.step_out)

			map("n", "<Leader>b", dap.toggle_breakpoint)
			map("n", "<Leader>B", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end)

			map("n", "<Leader>dr", dap.repl.open)
			map("n", "<Leader>dl", dap.run_last)
		end,
	},
}
