
class SPEC_CUSTOM_INSTRUCTIONS

  include DA_HTML::Printer

  def to_html(i : DA_HTML::Instruction)
    case
    when i.origin.first == "SAY_HELLO"
      io.write_text i.origin.last
    else
      super
    end
  end # === def to_html

  class Parser

    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "text!"
        content = x.content
        return x if !content.index("{{")
        content.split(/(\{\{[A-Z\_0-9]+\}\})/).each { |s|
          if s == "{{GREETING}}"
            doc.instruct "SAY_HELLO", "Howdy"
          else
            doc.instruct "text", s
          end
        }
        :done
      when "span"
        allow_body_tag(x, a: DA_HTML::SEGMENT_ATTR_ID, b: DA_HTML::SEGMENT_ATTR_ID)
      else
        allow_body_tag(x)
      end
    end # === def allow

  end # === class Parse

end # === class SPEC_CUSTOM_INSTRUCTIONS
describe "Custom instructions" do

  it "renders custom instructions" do
    input = %[ <span>{{GREETING}}: Hello</span> ]
    expect = %[<span>Howdy: Hello</span>]
    actual = SPEC_CUSTOM_INSTRUCTIONS.new(input, __DIR__).to_html
    should_eq actual, expect
  end # === it "renders custom instructions"

end # === desc "Custom instructions"
