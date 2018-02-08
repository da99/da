
class Attrs_02

  include DA_HTML::Base

end # === module Validator_02

describe "Attrs :closed_tag" do
  it "escapes values of attributes" do
    actual = Attrs_02.to_html {
      p(hello: "<joe>") { }
    }
    assert actual == "<p hello=\"&#x3c;joe&#x3e;\"></p>"
  end # === it "escapes values of attributes"

  it "allows single attributes: <input required ...>" do
    actual = Attrs_02.to_html {
      input_text(:required, maxlength: "10")
    }
    assert actual == %(<input maxlength="10" required>)
  end # === it "allows single attributes: <input required ...>"
end # === desc ":attrs"

