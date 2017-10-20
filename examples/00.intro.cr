
class Basic_Spec_HTML
  include DA_HTML::DOCTYPE
  include DA_HTML::HTML
  include DA_HTML::HEAD
  include DA_HTML::TITLE
  include DA_HTML::BODY
  include DA_HTML::SPAN
  include DA_HTML::P
  include DA_HTML::DIV
  include DA_HTML::TEMPLATE
  include DA_HTML::TEXT

  getter :io
  @io : DA_HTML::INPUT_OUTPUT | DA_HTML::TEMPLATE::INPUT_OUTPUT
  def initialize
    @io = DA_HTML::INPUT_OUTPUT.new
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
