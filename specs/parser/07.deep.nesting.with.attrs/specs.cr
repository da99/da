
class SPEC_DEEP_NESTING_WITH_ATTRS

  ATTR_PATTERN = DA_HTML::SEGMENT_ATTR_ID

  include DA_HTML::Printer

  class Parser
    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "text!"
        x
      when "bang"
        allow_body_tag(x, a: ATTR_PATTERN, b: ATTR_PATTERN, c: ATTR_PATTERN)
      when "div"
        allow_body_tag(x, name: ATTR_PATTERN)
      end
    end # === def allow
  end # === class DA_HTML::Parser

  def to_html(i : DA_HTML::Instruction)
    case
    when i.close_tag?("bang")
      io.close_tag "span"
    when i.open_tag?("bang")
      io.open_tag_attrs("span") {
        i.grab_attrs.each { |a|
          io.write_attr(a)
        }
      }
      io.raw! SPEC_DEEP_NESTING_WITH_ATTRS.new(i.grab_body, __DIR__).to_html
    else
      super
    end
  end # === def to_html

end # === class SPEC_DEEP_NESTING_WITH_ATTRS

describe "Deep Nesting With Attributes" do

  # This tests :grab_attrs and :grab_body in deep nesting structures.
  # In practice, this is unlikely to be needed, but it's a
  # "stress test" for Doc and Instruction reliability.
  it "renders properly deeply nested custom tags with attributes" do
    input = file_read!("input.html")
    expect = file_read!("expect.html")

    actual = SPEC_DEEP_NESTING_WITH_ATTRS.new(input, __DIR__).to_html
    should_eq actual, expect
  end # === it "renders properly deeply nested custom tags with attributes"

end # === desc "Deep Nesting With Attributes"
