
class Customize_01

  include DA_HTML::Base

  def p(**attrs)
    attrs.each { |k, v|
      case k
      when :id
        :ignore
      else
        raise DA_HTML::Invalid_Attr.new(k.inspect)
      end
    }
    with self yield self
  end

  def my_strong
    tag("strong") do
      with self yield self
    end
  end # === def my_strong

end # === struct Validator_01

describe "Customize" do

  it "raises an error if an invalid attr is requested" do
    assert_raises(DA_HTML::Invalid_Attr) {
      Customize_01.to_html { p(hello: "name") { "hello" } }
    }
  end # === it "raises an error if an invalid attr is requested"

  it "allows custom tags without attrs" do
    actual = Customize_01.to_html {
      my_strong { "yo & yo" }
    }
    assert actual == %[<strong>yo &#x26; yo</strong>]
  end # === it "allows custom tags without attrs"

end # === desc "Validator"

describe ".tag" do
  it "allows an id and class" do
    actual = Customize_01.to_html {
      tag("my_tag", "#the_id.red") {
        "my content"
      }
    }
    assert actual == %[<my_tag id="the_id" class="red">my content</my_tag>]
  end # === it "allows an id and class"

  it "allows custom attributes" do
    actual = Customize_01.to_html {
      tag("my_tag", red: "blue", blue: "green") {
        "my content"
      }
    }
    assert actual == %[<my_tag red="blue" blue="green">my content</my_tag>]
  end # === it "allows attributes"

  it "escapes custom attribute values" do
    actual = Customize_01.to_html {
      tag("my_tag", red: "blue & yellow", blue: "green & orange") {
        "my content"
      }
    }
    assert actual == %[<my_tag red="blue &#x26; yellow" blue="green &#x26; orange">my content</my_tag>]
  end # === it "escapes custom attribute values"

end # === desc ".tag"

