function Global_completeTags()
  local curline = vim.fn.line('.')
  local curcol = vim.fn.col('.')
  local start = vim.fn.searchpos('\\s', 'bn', curline)
  local startcol = math.max(0, start[2])
  local partialword = vim.api.nvim_buf_get_text(0, curline-1, startcol, curline-1, curcol, {})[1]

  -- Get the list of tags from the buffer.
  local it = vim.iter(vim.fn.getline(1, '$'))
    :filter(function(l) return l:match('^tags') end)
    :map(function(s) return vim.split(s,' ') end)
  local tags = vim.tbl_flatten(it:totable())
  tags = vim.iter(tags):filter(function(s) return s:match('^'..partialword) end)
    :totable()
  table.sort(tags)
  tags = vim.fn.uniq(tags)

  vim.fn.complete(startcol + 1, tags)
  return ''
end

vim.cmd([[
  inoremap <silent> <C-G><C-G> <C-R>=v:lua.Global_completeTags()<CR>
]])
