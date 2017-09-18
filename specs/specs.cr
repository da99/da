
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




# =============================================================================

def it(*args)
end
def it(*args, &blok)
end

it "raises error if opening another tag during attribute write" do
  HTML.to_io do
    span
    span
  end
end
