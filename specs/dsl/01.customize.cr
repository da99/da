
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
    tag(:strong) {
      text(yield)
    }
  end # === def my_strong

  def self.to_html
    page = new
    with page yield
    page.io.to_s
  end # def

end # === struct Validator_01

describe "Customize" do

  it "allows custom tags without attrs" do
    actual = Customize_01.to_html {
      my_strong { "yo & yo" }
    }
    assert actual == %[<strong>yo &#x26; yo</strong>]
  end # === it "allows custom tags without attrs"

end # === desc "Validator"


