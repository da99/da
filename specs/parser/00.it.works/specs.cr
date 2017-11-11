
class SPEC_IT_WORKS
  struct Parser
    include DA_HTML::Parser

    def parse(name : String, node : XML::Node)
      case name
      when "doctype!"
        allow_tag(node)
      when "html", "head", "title", "body"
        allow_tag(node)
      when "p"
        allow_tag(node)
      when "css", "js"
        allow_tag(node)

      when "js"
        allow_tag(node)
      end
    end # === def parse
  end # === struct Parser

  include DA_HTML::Printer

  def render(tag)
    return super unless tag.open_tag?
    tag_name = tag.tag_name

    case tag_name
    when "css"
      doc.grab_current if doc.current.close_tag?("css")
      io.raw! %(<link href="/main.css" rel="stylesheet">)

    when "js"
      doc.grab_current if doc.current.close_tag?("js")
      io.raw! %(<script src="/main.js" type="application/javascript"></script>)

    else
      super
    end # === case
  end # === def render_instruction

end # === class Spec_Parser

describe DA_HTML::Parser do
  input_file = "/input.html"
  expected   = File.read("#{__DIR__}/expected.html")

  it "works" do
    actual = SPEC_IT_WORKS.new(DA_HTML.file_read!(__DIR__, input_file), __DIR__).to_html
    should_eq strip(actual), strip(expected)
  end # === it "#{x.gsub(".", " ")}"
end # === describe
