
module Validator_Attrs_02

  extend DA_HTML::Validator

  def self.attr!(page, tag_name, name, val)
    true
  end

  def self.attr!(page, tag_name, name)
    true
  end # === def self.attr!

end # === module Validator_02

describe ":closed_tag" do
  it "escapes values of attributes" do
    actual = DA_HTML.to_html(Validator_Attrs_02) {
      p(hello: "<joe>") { }
    }
    assert actual == "<p hello=\"&#x3c;joe&#x3e;\"></p>"
  end # === it "escapes values of attributes"

  it "allows single attributes: <input required ...>" do
    actual = DA_HTML.to_html(Validator_Attrs_02) {
      closed_tag("input", {:maxlength, "10"}, {:required})
    }
    assert actual == %(<input maxlength="10" required>)
  end # === it "allows single attributes: <input required ...>"
end # === desc ":attrs"

