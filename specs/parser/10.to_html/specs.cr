
class SPEC_TO_HTML
  include DA_HTML::Printer

  def to_html(i : DA_HTML::Instruction)
    super
  end # === def to_html

  class Parser
    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "text!"
        x
      else
        allow_body_tag(x)
      end
    end # === def allow
  end # === class Parser
end # === class SPEC_TO_HTML

describe ":to_html" do

  it "raises Invalid_Printing if doc is already fin?" do
    input = %[<span></span>]
    doc = SPEC_TO_HTML::Parser.new(input).parse
    while doc.current?
      doc.grab_current
    end

    expect_raises(DA_HTML::Invalid_Printing) {
      SPEC_TO_HTML.new(doc, __DIR__).to_html
    }
  end # === it "raises Invalid_Printing if doc is already fin?"

  it "renders Doc if size of doc == 1" do
    input = %[text]
    doc = SPEC_TO_HTML::Parser.new(input).parse
    while doc.current?
      doc.grab_current
    end

    expect_raises(DA_HTML::Invalid_Printing) {
      SPEC_TO_HTML.new(doc, __DIR__).to_html
    }
  end # === it "renders Doc if size of doc == 1"

end # === desc ":to_html"
