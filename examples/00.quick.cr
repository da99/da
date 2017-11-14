
class Example_00_Quick

  include DA_HTML::Printer

  class Parser

    include DA_HTML::Parser

    def allow(name : String, node : XML::Node)
      case name
      when "text!"
        node
      when "doctype!", "html"
        allow_document_tag(node)
      when "head", "title"
        allow_head_tag(node)
      when "body", "var", "loop", "bang"
        allow_body_tag(node)
      when "template"
        allow_body_tag(node, on: /([a-z0-9\_]+)/)
      when "p", "div"
        allow_body_tag(node, id: DA_HTML::SEGMENT_ATTR_ID, class: DA_HTML::SEGMENT_ATTR_CLASS)
      end
    end # === def parse

  end # === class Parser

  def to_html(i : DA_HTML::Instruction)
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
    actual = Example_00_Quick.new(%[<p><bang>hello</bang></p>], __DIR__).to_html
    should_eq actual, "<p><strong>hello</strong></p>"
  end

end # === desc "Example_00_Quick"
