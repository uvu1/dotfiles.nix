local M = {}

local function normal_win(win)
  return win and vim.api.nvim_win_is_valid(win) and vim.fn.win_gettype(win) == ""
end

local function fallback_editor_win()
  local current = vim.api.nvim_get_current_win()

  if normal_win(current) then
    return current
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if normal_win(win) then
      return win
    end
  end

  return current
end

local function editor_win()
  local ok, kind = pcall(require, "pane-tabs.buffers.kind")

  if not ok then
    return fallback_editor_win()
  end

  local current = vim.api.nvim_get_current_win()

  if normal_win(current) and kind.is_editor(vim.api.nvim_win_get_buf(current)) then
    return current
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if normal_win(win) and kind.is_editor(vim.api.nvim_win_get_buf(win)) then
      return win
    end
  end

  return fallback_editor_win()
end

function M.term_height()
  local win = editor_win()
  local height = normal_win(win) and vim.api.nvim_win_get_height(win) or vim.o.lines
  local preferred = math.floor(height * 0.34)

  return math.max(1, math.min(16, math.max(10, preferred), height - 2))
end

function M.term_width()
  local win = editor_win()
  local width = normal_win(win) and vim.api.nvim_win_get_width(win) or vim.o.columns

  return math.max(1, width - 2)
end

function M.term_row()
  local win = editor_win()

  if not normal_win(win) then
    return math.max(0, vim.o.lines - M.term_height() - 2)
  end

  local position = vim.api.nvim_win_get_position(win)
  local height = vim.api.nvim_win_get_height(win)

  return math.max(0, position[1] + height - M.term_height() - 2)
end

function M.term_col()
  local win = editor_win()

  if not normal_win(win) then
    return 0
  end

  return vim.api.nvim_win_get_position(win)[2]
end

return M
