local M = {}

local dap = require 'dap'

-- --------------------------------
-- solution + project helpers
-- --------------------------------

local function find_solution()
  local slnx = vim.fn.glob('*.slnx', false, true)
  if #slnx > 0 then
    return slnx[1], 'slnx'
  end

  local sln = vim.fn.glob('*.sln', false, true)
  if #sln > 0 then
    return sln[1], 'sln'
  end

  return nil, nil
end

local function parse_sln_projects(sln)
  local projects = {}
  for line in io.lines(sln) do
    local path = line:match 'Project%("%{.-%}"%) = ".-", "(.+%.csproj)"'
    if path then
      table.insert(projects, vim.fn.fnamemodify(path, ':p'))
    end
  end
  return projects
end

local function parse_slnx_projects(slnx)
  local projects = {}
  for line in io.lines(slnx) do
    local path = line:match 'Path="([^"]+%.csproj)"'
    if path then
      table.insert(projects, vim.fn.fnamemodify(path, ':p'))
    end
  end
  return projects
end

local function is_test_project(path)
  return path:match 'Test' or path:match 'Tests'
end

local function is_executable_csproj(csproj)
  for line in io.lines(csproj) do
    if line:match '<OutputType>Exe</OutputType>' then
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
    prompt = 'Select startup DLL',
    format_item = function(item)
      return item:gsub(vim.fn.getcwd() .. '/', '')
    end,
  }, cb)
end

local function find_startup_dll_async(cb)
  local solution, kind = find_solution()
  local projects = {}

  if solution then
    projects = kind == 'slnx' and parse_slnx_projects(solution) or parse_sln_projects(solution)
  end

  local candidates = {}

  for _, csproj in ipairs(projects) do
    if vim.fn.filereadable(csproj) == 1 and is_executable_csproj(csproj) and not is_test_project(csproj) then
      local dlls = vim.fn.glob(vim.fn.fnamemodify(csproj, ':h') .. '/bin/Debug/**/*.dll', true, true)
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
    cb(candidates[1])
    return
  end

  -- fallback picker
  local dlls = vim.fn.glob('**/bin/Debug/**/*.dll', true, true)
  pick_dll(dlls, cb)
end

-- --------------------------------
-- build + debug
-- --------------------------------

function M.build_and_debug()
  vim.notify('dotnet build', vim.log.levels.INFO)

  vim.fn.jobstart({ 'dotnet', 'build' }, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify('Build failed', vim.log.levels.ERROR)
        return
      end

      find_startup_dll_async(function(dll)
        if not dll then
          return
        end

        dap.run {
          type = 'coreclr',
          name = 'Launch',
          request = 'launch',
          program = dll,
        }
      end)
    end,
  })
end

return M
