
class A_Spec_HTML

  include DA_HTML::DSL::SPAN
  include DA_HTML::DSL::A

  getter :io
  def initialize
    @io = DA_HTML::IO_HTML.new
  end # === def initialize

  def render
    with self yield
    to_html
  end # === def render

  def to_html
    @io.to_html
  end # === def to_html

end # === class A_Spec_HTML

describe "a tag" do
  it "sanitizes javascript :href values" do
    actual = A_Spec_HTML.new.render {
      a(href: "javascript://a") { "my page" }
    }
    should_eq actual, %(<a href="#invalid">my page</a>)
  end # === it "sanitizes javascript :href values"

  it "allows :id attribute" do
    actual = A_Spec_HTML.new.render {
      a("#main", href: "/page") { "the page" }
    }
    should_eq actual, %(<a id="main" href="/page">the page</a>)
  end # === it "allows :id attribute"
end # === desc "a tag"
