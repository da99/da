
class SPEC_PARSE_TEXT

  include DA_HTML::Printer

  class Parser

    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "text!"
        txt = x.content
        if txt
          return txt.gsub("{{hello}}", "Howdy") if txt.index("{{")
          return txt
        end
        :done

      when "div"
        allow_body_tag(x)

      when "bang"
        x.name = "span"
        allow_body_tag(x)
      end
    end # === def allow

  end # === class Parser
end # === class SPEC_PARSE_TEXT

describe "Parse text nodes" do
  it "ignores text node if :done is returned" do
    input = %[ <bang>{{hello}}: Hello</bang><div>text</div> ]
    expect = %[ <span>Howdy: Hello</span><div>text</div> ]

    actual = SPEC_PARSE_TEXT.new(input, __DIR__).to_html

    should_eq actual, expect
  end # === it "ignores text node if :done is returned"
end # === desc "Parse text nodes"
