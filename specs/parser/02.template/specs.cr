
struct SPECS_TEMPLATE

  include DA_HTML::Parser
  include DA_HTML::Parser::Template

  def_tags :html , :head , :title , :body , :p, :div, :link
  finish_def_html!

end # === class SPECS_TEMPLATE

describe "Parser template tag" do

  it "adds type attr to script tag" do
    x = __DIR__ + "/adds_type_attr_to_script_template"
    expect = File.join(x, "expect.html")
    input  = File.join(x, "input.html")
    actual = SPECS_TEMPLATE.new("input.html", x).to_html
    should_eq strip(actual), strip(File.read(expect))
  end

  it "multi-escapes nested templates" do
    x = __DIR__ + "/nested_template_tags"
    expect = File.join(x, "expect.html")
    input  = File.join(x, "input.html")
    actual = SPECS_TEMPLATE.new("input.html", x).to_html
    should_eq strip(actual), strip(File.read(expect))
  end # === it "multi-escapes nested templates"

end # === desc "parser"
