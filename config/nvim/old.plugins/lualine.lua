
-- =====================================
-- LuaLine:
-- =====================================
local function a_file()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype
  return not (ft == "help" or ft == "alpha" or ft == "" or bt == "terminal" or bt == "nofile")
end

local function dirname()
  -- local ft = vim.bo.filetype
  if a_file() or vim.bo.filetype == "help" then
    local filename = fn.expand('%')
    local basename = fn.fnamemodify(filename, ":t")
    local dir      = fn.fnamemodify(filename, ":h")
    local base_dir = fn.fnamemodify(dir, ":t")
    return base_dir.."/"..basename
  elseif vim.bo.buftype == "terminal" then
    return fn.matchstr(fn.expand('%'), '[^:]\\+$')
  else
    return ""
  end
  --  if vim.bo.modified then
  --  elseif vim.bo.modifiable  vim.bo.readonly
end -- function

local function branch_or_base_name(x)
  local ft = vim.bo.filetype
  if (ft == "help" or ft == "alpha" or ft == "") then
    return ""
  else
    return x
  end
end -- function

require('lualine').setup {
  options = {
    theme = 'onedark',
    component_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { },
    lualine_c = {{'branch', fmt = branch_or_base_name}, dirname, 'filetype'},
    lualine_x = { },
    lualine_y = { 'diagnostics', 'fileformat', 'encoding', 'progress', 'location' },
    lualine_z = { },
  },
  inactive_sections = {
    lualine_a = { 'filename', dirname },
    lualine_b = { },
    lualine_c = { },
    lualine_x = { },
    lualine_y = { },
    lualine_z = { },
  }
}
-- =============================================================================
-- End LuaLine
-- =============================================================================

