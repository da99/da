
class Example_01_Manual
  include DA_HTML::DSL::DOCTYPE
  include DA_HTML::DSL::HTML
  include DA_HTML::DSL::HEAD
  include DA_HTML::DSL::TITLE
  include DA_HTML::DSL::BODY
  include DA_HTML::DSL::SPAN
  include DA_HTML::DSL::P
  include DA_HTML::DSL::DIV
  include DA_HTML::DSL::TEMPLATE
  include DA_HTML::DSL::TEXT

  getter :io
  @io : DA_HTML::IO_HTML | DA_HTML::DSL::TEMPLATE::INPUT_OUTPUT
  def initialize
    @io = DA_HTML::IO_HTML.new
  end # === def initalize

  def self.render
    h = new
    with h yield
    h.io.to_html
  end

  def to_html
    @io.to_html
  end # === def to_html

end # === class HTML


describe "Example_01_Manual" do
  it "renders html" do
    actual = Example_01_Manual.render {
      p { "manual, not auto" }
    }
    should_eq actual, %(
      <p>manual, not auto</p>
    )
  end # === it "renders html"
end # === desc "Example_01_Manual"
