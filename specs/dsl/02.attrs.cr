
class Attrs_02

  include DA_HTML::Base

  def span(**attrs)
    raw! "<span"
    attrs.each { |k, v|
      attr! k, v
    }
    raw! '>'
    with self yield self
    raw! "</span>"
  end

end # === module Validator_02

describe "Attrs :closed_tag" do
  it "escapes values of attributes" do
    actual = Attrs_02.to_html {
      span(hello: "<joe>") { }
    }
    assert actual == "<span hello=\"&#x3c;joe&#x3e;\"></span>"
  end # === it "escapes values of attributes"

  it "allows single attributes: <input required ...>" do
    actual = Attrs_02.to_html {
      input_text(:required, maxlength: 10)
    }
    assert actual == %(<input type="text" required maxlength="10">)
  end # === it "allows single attributes: <input required ...>"
end # === desc ":attrs"

