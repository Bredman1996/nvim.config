return {
	"fschaal/azfunc.nvim",
	config = function()
		require("azfunc").setup({
			debug = {
				adapter = "coreclr",
				attach_retry_count = 20,
				retry_interval = 2000,
				attach_timeout = 1000,
			},
			terminal = {
				split = "vsplit",
				size = nil,
			},
			func_cli = {
				command = "func",
				args = "host start --port 7078 --dotnet-isolated-debug",
			},
		})
	end,
}
