
struct SPEC_ATTRS

  include DA_HTML::Printer

  struct Parser
    include DA_HTML::Parser

    def allow(name : String, node : XML::Node)
      case name
      when "text!"
        node
      when "doctype!", "html"
        allow_document_tag(node)
      when "head", "body"
        allow_html_tag(node)
      when "title"
        allow_head_tag(node)
      when "p", "div", "bang"
        allow_body_tag(node, id: DA_HTML::SEGMENT_ATTR_ID, class: DA_HTML::SEGMENT_ATTR_CLASS)
      end
    end # === def self.parse
  end # === struct Parser

  def to_html(tag : DA_HTML::Instruction)
    case
    when tag.open_tag?("css")
      io.raw! %(<link href="/main.css" rel="stylesheet">)
    when tag.open_tag?("js")
      io.raw! %(<script src="/main.js" type="application/javascript"></script>)

    when tag.open_tag?("bang")
      io.open_tag_attrs("span") {
      }
    else
      super
    end
  end # === def print

end # === class Spec_Parser

describe "Parser attrs" do
  input_file = "/input.html"
  expected   = File.read("#{__DIR__}/expected.html")

  it "renders attributes" do
    actual = SPEC_ATTRS.new(DA_HTML.file_read!(__DIR__, input_file), __DIR__).to_html
    should_eq strip(actual), strip(expected)
  end # === it "#{x.gsub(".", " ")}"

  it "raises an error if attributes are not consumed" do
    input = %[<bang id="a1">hello</bang]
    expect = %[<span id="a1">hello</span>]
    expect_raises(DA_HTML::Invalid_Printing) {
      txt = SPEC_ATTRS.new(input, __DIR__).to_html
      puts txt
    }
  end # === it "raises an error if attributes are not consumed"
end # === describe
