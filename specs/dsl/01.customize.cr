
class Customize_01

  include DA_HTML::Base
  include DA_HTML::STRONG::Tag

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

  it "allows custom tags without attrs" do
    actual = Customize_01.to_html {
      strong { "yo & yo" }
    }
    assert actual == %[<strong>yo &#x26; yo</strong>]
  end # === it "allows custom tags without attrs"

end # === desc "Validator"
