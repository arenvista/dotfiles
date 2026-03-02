local M = {}

-- Search for tags like ^proof-induction
M.search_markdown_tags = function(tag)
  local term = "^" .. tag
  local cmd = string.format('rg --vimgrep "%s" --glob "*.md"', term)
  -- Open results in quickfix
  vim.cmd("cgetexpr systemlist('" .. cmd .. "')")
  vim.cmd("copen")
end

return M
