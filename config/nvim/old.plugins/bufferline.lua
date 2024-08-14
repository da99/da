
-- =====================================
-- BufferLine
-- =====================================
require('bufferline').setup({
  highlights = {
    -- tab = { bg = "#000000" },
    background = { bg = "#000000" },
    fill = { bg = "#000000" },
    tab            = { bg = "#000000" },
    buffer_visible = { bg = "#000000" },
  },
  options = {
    show_buffer_close_icons = false,
    separator_style = "thin",
    diagnostics = "nvim_lsp",
    numbers = function(opts)
      return string.format('%s·%s', opts.ordinal, opts.id)
    end
  }
})
