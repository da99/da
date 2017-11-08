
struct SPECS_TEMPLATE

  include DA_HTML::Parser

  def self.parse_tag(name : String | Symbol, node : XML::Node)
    case name
    when :doctype!
      allow_tag(node)
    when "html", "head", "title", "body", "link"
      allow_tag(node)
    when "template", "var", "loop"
      allow_tag(node)
    when "p", "div"
      allow_tag_with_attributes(node, "id", "class")
    end
  end # === def parse

  macro spec(name)
    x = __DIR__ + "{{name.id}}"

    expect = File.join(x, "expect.html")
    input  = File.join(x, "input.html")
    actual = SPECS_TEMPLATE.new_from_file("input.html", x).to_html
    should_eq actual, File.read expect
  end # === macro spec

end # === class SPECS_TEMPLATE

describe "Parser template tag" do

  it "adds type attr to script tag" do
    SPECS_TEMPLATE.spec "/adds_type_attr_to_script_template"
  end

  it "multi-escapes nested templates" do
    SPECS_TEMPLATE.spec "/nested_template_tags"
  end # === it "multi-escapes nested templates"

  it "renders custom attributes" do
    SPECS_TEMPLATE.spec "/uses_custom_template_attrs"
  end # === it "renders custom attributes"

  it "does not override template attrs" do
    SPECS_TEMPLATE.spec "/no_override_template_attrs"
  end # === it "does not override template attrs"

end # === desc "parser"
