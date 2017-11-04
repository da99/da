
struct SPECS_TEMPLATE

  include DA_HTML::Parser
  include DA_HTML::Parser::Template

  def_tags :html , :head , :title , :body , :p, :div, :link
  finish_def_html!

  macro spec(name)
    x = __DIR__ + "{{name.id}}"
    expect = File.join(x, "expect.html")
    input  = File.join(x, "input.html")
    actual = SPECS_TEMPLATE.new("input.html", x).to_html
    should_eq strip(actual), strip(File.read(expect))
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
