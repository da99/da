
struct SPEC_ATTRS

  include DA_HTML::Printer

  struct Parser
    include DA_HTML::Parser

    def parse(name : String, node : XML::Node)
      case name
      when "doctype!"
        allow_tag(node)
      when "html", "head", "title", "body"
        allow_tag(node)
      when "p", "div"
        allow_tag_with_attrs(node, id: DA_HTML::SEGMENT_ATTR_ID, class: DA_HTML::SEGMENT_ATTR_CLASS)
      end
    end # === def self.parse
  end # === struct Parser

  def render(tag_name : DA_HTML::Instruction)
    case tag_name
    when "css"
      io.raw! %(<link href="/main.css" rel="stylesheet">)
    when "js"
      io.raw! %(<script src="/main.js" type="application/javascript"></script>)
    else
      super
    end
  end # === def render

end # === class Spec_Parser

describe DA_HTML::Parser do
  input_file = "/input.html"
  expected   = File.read("#{__DIR__}/expected.html")

  it "renders attributes" do
    actual = SPEC_ATTRS.new(DA_HTML.file_read!(__DIR__, input_file), __DIR__).to_html
    should_eq strip(actual), strip(expected)
  end # === it "#{x.gsub(".", " ")}"
end # === describe
