
class Customize_01

  include DA_HTML::Base

  def tag!(page, tag_name)
    return false if tag_name == "span"
    true
  end # === def self.validate

  def attr!(page, tag_name, name, val)
    return true unless name == :hello
    false
  end # === def self.validate

end # === struct Validator_01

describe "Customize" do

  it "raises an error if an invalid attr is requested" do
    assert_raises(DA_HTML::Invalid_Attr) {
      Customize_01.to_html { p(hello: "name") { "hello" } }
    }
  end # === it "raises an error if an invalid attr is requested"

  it "raises an error if an invalid tag is requested" do
    assert_raises(DA_HTML::Invalid_Tag) {
      Customize_01.to_html { span { "hello" } }
    }
  end # === it "raises an error if an invalid tag is requested"

end # === desc "Validator"
