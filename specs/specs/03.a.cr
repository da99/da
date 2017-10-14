
class A_Spec_HTML

  include DA_HTML::SPAN
  include DA_HTML::A

  getter :io
  def initialize
    @io = DA_HTML::INPUT_OUTPUT.new
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
end # === desc "a tag"
