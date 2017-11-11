
class Example_00_Quick

  include DA_HTML::Printer

  class Parser

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

  end # === class Parser

  def render(i : DA_HTML::Instruction)
    case
    when i.open_tag?("bang")
      io.open_tag "strong"
      io.write_text self.class.new(i.grab_body, file_dir).to_html
      io.close_tag "strong"
      doc.grab_current
    else
      super
    end
  end

end # === class HTML

describe "Example_00_Quick" do

  it "renders html" do
    actual = Example_00_Quick.new(%[<p>hello</p>], __DIR__).to_html

    should_eq actual, " <p>hello</p> "
  end

  it "renders html using :to_html" do
    actual = Example_00_Quick.new(%[<p>h</p>], __DIR__).to_html
    should_eq actual, "<p>h</p>"
  end # === it "renders html using :to_html"

end # === desc "Example_00_Quick"
