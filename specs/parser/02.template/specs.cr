
struct SPECS_TEMPLATE

  include DA_HTML::Printer

  struct Parser

    include DA_HTML::Parser

    def parse_tag(name : String | Symbol, node : XML::Node)
      case name
      when :doctype!
        allow_tag(node)
      when "head"
        allow_tag(node)
      when "html", "title", "body", "link"
        allow_tag(node)
      when "template", "var", "loop"
        allow_tag_with_attrs(node, on: /([a-z0-9\_]+)/)
      when "var", "loop"
        allow_tag(node)
      when "p", "div"
        allow_tag_with_attrs(node, id: DA_HTML::SEGMENT_ATTR_ID, class: DA_HTML::SEGMENT_ATTR_CLASS)
      end
    end # === def parse

  end # === struct Parser

  def render(tag : DA_HTML::Instruction)
    case
    when tag.close_tag?("template")
      io.close_tag("script")

    when tag.open_tag?("template")
      io.open_tag_attrs("script") { |io_html|
        io.write_attr("type", "application/template")
        tag.grab_attrs.each { |a|
          io.write_attr("data-" + a.attr_name, a.attr_content)
        }
      }

      html = self.class.new(tag.grab_body, file_dir).to_html
      io.write_text( html )
    else
      super
    end
  end # === def render

  macro spec(name)
    x = __DIR__ + "{{name.id}}"

    expect = File.join(x, "expect.html")
    input  = File.join(x, "input.html")
    actual = SPECS_TEMPLATE.new(File.read(input), x).to_html
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
