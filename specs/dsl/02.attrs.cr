
class Attrs_02

  include DA_HTML::Base

  def attr!(page, tag_name, name, val)
    true
  end

  def attr!(page, tag_name, name)
    true
  end # === def self.attr!

end # === module Validator_02

describe ":closed_tag" do
  it "escapes values of attributes" do
    actual = Attrs_02.to_html {
      p(hello: "<joe>") { }
    }
    assert actual == "<p hello=\"&#x3c;joe&#x3e;\"></p>"
  end # === it "escapes values of attributes"

  it "allows single attributes: <input required ...>" do
    actual = Attrs_02.to_html {
      closed_tag("input", {:maxlength, "10"}, {:required})
    }
    assert actual == %(<input maxlength="10" required>)
  end # === it "allows single attributes: <input required ...>"
end # === desc ":attrs"

