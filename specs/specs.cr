
require "../src/html.cr"

puts(HTML.to_html do
  span
    .id_("main_msg")
    .class_("loud")
    .close("hello")
end)
