
class SPEC_WRITE_CLOSED_TAG
  include DA_HTML::Printer

  def to_html(i : DA_HTML::Instruction)
    case
    when i.open_tag?("js")
      io.write_closed_tag("link", {"hello", "goodbye"})
    when i.close_tag?("js")
      :done
    else
      super
    end
  end # === def to_html

  class Parser
    include DA_HTML::Parser
    def allow(name : String, x : XML::Node)
      case name
      when "text!"
        x
      when "js"
        allow_body_tag(x)
      end
    end # === def allow
  end # === class Parser

end # === class SPEC_WRITE_CLOSED_TAG

describe ":write_closed_tag" do
  it "writes a tag that has no closing tag" do
    input = %[ <js> ]
    expect = %[<link hello="goodbye">]
    actual = SPEC_WRITE_CLOSED_TAG.new(input, __DIR__).to_html
    should_eq expect, actual
  end # === it "writes a tag that has no closing tag"
end # === desc ":write_closed_tag"
