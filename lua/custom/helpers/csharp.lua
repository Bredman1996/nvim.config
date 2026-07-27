local M = {}

local dap = require("dap")

-- --------------------------------
-- solution + project helpers
-- --------------------------------

local function find_solution()
	local slnx = vim.fn.glob("*.slnx", false, true)
	if #slnx > 0 then
		return slnx[1], "slnx"
	end

	local sln = vim.fn.glob("*.sln", false, true)
	if #sln > 0 then
		return sln[1], "sln"
	end

	return nil, nil
end

local function parse_sln_projects(sln)
	local projects = {}
	for line in io.lines(sln) do
		local path = line:match('Project%("%{.-%}"%) = ".-", "(.+%.csproj)"')
		if path then
			table.insert(projects, vim.fn.fnamemodify(path, ":p"))
		end
	end
	return projects
end

local function parse_slnx_projects(slnx)
	local projects = {}
	for line in io.lines(slnx) do
		local path = line:match('Path="([^"]+%.csproj)"')
		if path then
			table.insert(projects, vim.fn.fnamemodify(path, ":p"))
		end
	end
	return projects
end

local function is_test_project(path)
	return path:match("Test") or path:match("Tests")
end

local function is_executable_csproj(csproj)
	for line in io.lines(csproj) do
		if line:match("<OutputType>Exe</OutputType>") then
			return true
		end
	end
	return false
end

local function is_azurefunction_csproj(csproj)
	for line in io.lines(csproj) do
		if line:match("<AzureFunctionsVersion>v4</AzureFunctionsVersion>") then
			return true
		end
	end
	return false
end

-- --------------------------------
-- dll resolution
-- --------------------------------

local function pick_dll(dlls, cb)
	vim.ui.select(dlls, {
		prompt = "Select startup DLL",
		format_item = function(item)
			return item:gsub(vim.fn.getcwd() .. "/", "")
		end,
	}, cb)
end

local function find_startup_dll_async(cb)
	local solution, kind = find_solution()
	local projects = {}

	if solution then
		projects = kind == "slnx" and parse_slnx_projects(solution) or parse_sln_projects(solution)
	end

	local candidates = {}

	for _, csproj in ipairs(projects) do
		if vim.fn.filereadable(csproj) == 1 and is_executable_csproj(csproj) and not is_test_project(csproj) then
			if is_azurefunction_csproj(csproj) then
				cb(csproj:match("(.*[/\\])"), "AzureFunc")
				return
			end

			local dlls = vim.fn.glob(vim.fn.fnamemodify(csproj, ":h") .. "/bin/Debug/**/*.dll", true, true)
			table.sort(dlls, function(a, b)
				return vim.fn.getftime(a) > vim.fn.getftime(b)
			end)
			if dlls[1] then
				table.insert(candidates, dlls[1])
			end
		end
	end

	if #candidates > 0 then
		table.sort(candidates, function(a, b)
			return vim.fn.getftime(a) > vim.fn.getftime(b)
		end)
		cb(candidates[1], "Normal")
		return
	end

	-- fallback picker
	local dlls = vim.fn.glob("**/bin/Debug/**/*.dll", true, true)
	pick_dll(dlls, cb)
end

-- --------------------------------
-- build + debug
-- --------------------------------
function M.build_and_debug()
	vim.notify("dotnet build", vim.log.levels.INFO)
	local stdout = { "Build stdout:" }
	local stderr = { "Build stderr:" }
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

		local profile_name
		local profile

		for name, p in pairs(parsed.profiles) do
			if p.commandName == "Project" then
				profile_name = name
				profile = p
				break
			end
		end

		if not profile then
			vim.notify("Didn't find a project profile", vim.log.levels.WARN)
			return {}
		end

		return {
			profile_name = profile_name,
			applicationUrl = profile.applicationUrl,
			environmentVariables = profile.environmentVariables or {},
			commandLineArgs = profile.commandLineArgs or {},
		}
	end

	vim.fn.jobstart({ "dotnet", "build" }, {
		on_stdout = function(_, data, event)
			for key, value in pairs(data) do
				table.insert(stdout, string.format("%s", value))
			end
		end,
		on_stderr = function(_, data, event)
			for key, value in pairs(data) do
				table.insert(stderr, string.format("%s", value))
			end
		end,
		on_exit = function(id, code, event)
			if #stdout > 1 then
				vim.notify(table.concat(stdout, "\n\t"), vim.log.levels.INFO)
			end
			if #stderr > 1 then
				vim.notify(table.concat(stderr, "\n\t"), vim.log.levels.ERROR)
			end

			if code ~= 0 then
				vim.notify("Build failed", vim.log.levels.ERROR)
				return
			end

			find_startup_dll_async(function(dll, type)
				if not dll then
					vim.notify("No dll sent", vim.log.levels.INFO)
					return
				end
				if type ~= "AzureFunc" then
					dap.run({
						type = "coreclr",
						name = "Launch",
						request = "launch",
						program = dll,
						env = function()
							local profile = load_launch_settings()
							return vim.tbl_extend("force", profile.environmentVariables, {
								ASPNETCORE_URLS = profile.applicationUrl,
							})
						end,
						-- args = function()
						-- 	local profile = load_launch_settings()
						-- 	if profile and profile.commandLineArgs then
						-- 		return vim.split(profile.commandLineArgs, " ")
						-- 	end
						-- 	return {}
						-- end,
					})
				end
				if type == "AzureFunc" then
					require("azfunc").start_from_path(dll)
				end
			end)
		end,
	})
end

return M
