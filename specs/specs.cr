
require "../src/html.cr"

class HTML
  include SPAN::Markup
end # === class HTML

io = HTML.to_io do

  span { "yo" }
  span.class_("shy") { "" }
  span.id_("main_msg").class_("loud") { "hello" }

end

puts io
