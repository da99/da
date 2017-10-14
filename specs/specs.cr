
require "../src/da_html"
require "../src/da_html/tags/*"
require "spec"

class Test_HTML
  include DA_HTML::DOCTYPE
  include DA_HTML::HTML
  include DA_HTML::HEAD
  include DA_HTML::TITLE
  include DA_HTML::BODY
  include DA_HTML::SPAN
  include DA_HTML::P
  include DA_HTML::DIV

  getter :io
  def initialize
    @io = DA_HTML::Io.new
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

macro strip(str)
  {{str}}.strip.gsub("\n", "").gsub(/>\s+</, "><")
end

it "renders p tag" do
  actual = Test_HTML.render { p { "hello" } }
  should_eq actual, "<p>hello</p>"
end # === it "renders p tag"

it "renders tags within tags" do
  actual = Test_HTML.render {
    div {
      p { span { "hello"} }
      p { }
    }
  }

  should_eq actual, "<div><p><span>hello</span></p><p></p></div>"
end # === it "renders tags within tags"

it "renders doctype" do
  actual = Test_HTML.render {
    doctype!
    html {
      head {
        title "Hello"
      }
      body {
        p { "done" }
      }
    }
  }

  should_eq actual, strip(%(
    <!DOCTYPE html>
    <html>
      <head>
        <title>Hello</title>
      </head>
      <body><p>done</p></body>
    </html>
  ))
end # === it "renders doctype"

{% for x in %w(div p span) %}
  it "renders id and classes on {{x.id}}" do
    actual = Test_HTML.render {
      {{x.id}}("#pepper", "red", "hot") { "spicy" }
    }

    should_eq actual, %{<{{x.id}} id="pepper" class="red hot">spicy</{{x.id}}>}
  end # === it "renders id and classes"
{% end %}


