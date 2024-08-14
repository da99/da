
-- =============================================================================
-- Kommentary:
-- =============================================================================
local komm = require('kommentary.config')
set_keymap('n', '<Leader>kommd', '<Plug>kommentary_line_decrease', {})
komm.configure_language("default", {
  prefer_single_line_comments = true,
  ignore_whitespace = false
})
komm.configure_language("fish", {
  prefer_single_line_comments = true,
  single_line_comment_string = "#",
})
-- =============================================================================
