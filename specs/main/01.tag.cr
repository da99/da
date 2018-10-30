
class Customize_Tag_01

  include DA_HTML::Base

  def name(v : String)
    DA_HTML::Attribute.new(:name, v)
  end # def

  def red
    DA_HTML::Attribute.new(:red)
  end # def

  def red(x)
    DA_HTML::Attribute.new(:red, x)
  end # def

  def blue(x)
    DA_HTML::Attribute.new(:blue, x)
  end

  def selected
    DA_HTML::Attribute.new(:selected)
  end # === def

  def self.to_html
    page = new
    with page yield
    page.io.to_s
  end # def

end # === struct Validator_01

describe ".tag" do
  it "allows an id and class" do
    actual = DA_HTML.to_html {
      tag(:my_tag, "#the_id.red") {
        text "my content"
      }
    }
    assert actual == %[<my_tag id="the_id" class="red">my content</my_tag>]
  end # === it "allows an id and class"

  it "allows custom attributes" do
    actual = Customize_Tag_01.to_html {
      tag(:my_tag, red("blue"), blue("green")) {
        text "my content"
      }
    }
    assert actual == %[<my_tag red="blue" blue="green">my content</my_tag>]
  end # === it "allows attributes"

  it "escapes custom attribute values" do
    actual = Customize_Tag_01.to_html {
      tag(:my_tag, red("blue & yellow"), blue("green & orange")) {
        text "my content"
      }
    }
    assert actual == %[<my_tag red="blue &#x26; yellow" blue="green &#x26; orange">my content</my_tag>]
  end # === it "escapes custom attribute values"

  it "allows single name attributes" do
    actual = Customize_Tag_01.to_html {
      tag(:my_tag, red) { }
    }
    assert actual == %[<my_tag red></my_tag>]
  end # === it "allows single name attributes"

  it "creates a self-closing tag when no block is given" do
    actual = Customize_Tag_01.to_html {
      tag(:input, selected)
    }
    assert actual == %[<input selected>]
  end # === it "creates a self-closing tag when no block is given"

  it "allows name: as an attribute" do
    actual = Customize_Tag_01.to_html {
      tag(:input, selected, name("something"))
    }
    assert actual == %[<input selected name="something">]
  end # === it "allows name: as an attribute"

end # === desc ".tag"
