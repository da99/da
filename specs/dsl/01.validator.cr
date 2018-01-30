
class Validator_01

  extend DA_HTML::Validator

  def self.tag!(page, tag_name)
    return false if tag_name == "span"
    true
  end # === def self.validate

  def self.attr!(page, tag_name, name, val)
    return true unless name == :hello
    false
  end # === def self.validate

end # === struct Validator_01

describe "Validator" do

  it "allows a Validator" do
    actual = DA_HTML.to_html(Validator_01) { p { "hello" } }
    assert actual == %[<p>hello</p>]
  end # === it "allows a Validator"

  it "raises an error if an invalid attr is requested" do
    assert_raises(DA_HTML::Invalid_Attr) {
      DA_HTML.to_html(Validator_01) { p(hello: "name") { "hello" } }
    }
  end # === it "raises an error if an invalid attr is requested"

  it "raises an error if an invalid tag is requested" do
    assert_raises(DA_HTML::Invalid_Tag) {
      DA_HTML.to_html(Validator_01) { span { "hello" } }
    }
  end # === it "raises an error if an invalid tag is requested"

end # === desc "Validator"
