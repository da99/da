
require "../src/da_html"

require "../src/da_html/tags/*"

class Test_HTML
  include DA_HTML::SPAN
  include DA_HTML::P

  @io : DA_HTML::Page
  getter :io
  def initialize
    @io = DA_HTML::Page.new
  end # === def initalize

  def self.render
    h = new
    with h yield
    h.io.to_html
  end
end # === class HTML

io = Test_HTML.render do

  p { "hello" }
  span {
    p { "yo" }
  }
  span("shy") { "" }

  span("#main_msg loud") { "hello" }

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
