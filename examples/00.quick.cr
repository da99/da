
class Example_00_Quick
  include DA_HTML::DSL

  def do_this
    with self yield
  end

end # === class HTML

describe "Example_00_Quick" do

  it "renders html" do
    actual = Example_00_Quick.to_html {
      p {
        "hello"
      }
    }

    should_eq actual, %(
      <p>hello</p>
    )
  end

  it "renders html using :to_html" do
    page = Example_00_Quick.new
    page.do_this {
      p { "h" }
    }
    should_eq page.to_html, %(
      <p>h</p>
    )
  end # === it "renders html using :to_html"

end # === desc "Example_00_Quick"
