
class Attrs_02

  include DA_HTML::Base

  def hello(s)
    DA_HTML::HTML_Attribute.new(:hello, s)
  end # def

  def span(*attrs)
    tag(:span, *attrs) {
      result = yield
      text(result) if result.is_a?(String)
    }
  end # def

  def required
    DA_HTML::HTML_Attribute.new(:required)
  end

  def maxlength(x : Int32)
    DA_HTML::HTML_Attribute.new(:maxlength, x.to_s)
  end

  def input_text(*attrs)
    tag(:input, DA_HTML::HTML_Attribute.new(:type, "text"), *attrs)
  end # def

  def self.to_html
    page = new
    with page yield
    page.io.to_s
  end # def

end # === module Validator_02

describe "Attrs :closed_tag" do
  it "escapes values of attributes" do
    actual = Attrs_02.to_html {
      span(hello("<joe>")) { }
    }
    assert actual == "<span hello=\"&#x3c;joe&#x3e;\"></span>"
  end # === it "escapes values of attributes"

  it "allows single attributes: <input required ...>" do
    actual = Attrs_02.to_html {
      input_text(required, maxlength(10))
    }
    assert actual == %(<input type="text" required maxlength="10">)
  end # === it "allows single attributes: <input required ...>"
end # === desc ":attrs"

