
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


