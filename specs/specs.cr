
require "../src/da_html"
require "../src/da_html/tags/*"
require "spec"

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

# puts Test_HTML.render {

#   span {
#     p { "yo" }
#   }
#   span("shy") { "" }

#   span("#main_msg loud") { "hello" }

# }

macro should_eq(actual, expected)
  {{actual}}.should eq({{expected}})
end # === macro should_eq

it "renders p tag" do
  actual = Test_HTML.render { p { "hello" } }
  should_eq actual, "<p>hello</p>"
end # === it "renders p tag"



