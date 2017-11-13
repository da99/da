
class SPEC_A_TAG

  include DA_HTML::Printer

  def to_html(i : DA_HTML::Instruction)
    super
  end # === def to_html

  class Parser

    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "a"
        allow_body_tag(x, href: /[a-z\/]+/, target: /_blank/, rel: /(archives)/)
      end
    end # === def allow

  end # === class Parser

end # === class SPEC_A_TAG
describe "a tag" do
  # Handle this "window.opener API." security vulnerability:
  #  https://news.ycombinator.com/item?id=15685324
  #  https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/
  #  https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a
  it "adds rel=\"nofollow noopener noreferrer\" when target attr is used" do
    input = %[
      <a href="/a">a</a>
      <a href="/b" target="_blank">b</a>
    ]
    expect = %[
      <a href="/a">a</a>
      <a href="/b" target="_blank" rel="nofollow noopener noreferrer">b</a>
    ]

    actual = SPEC_A_TAG.new(input, __DIR__).to_html
    should_eq actual, expect
  end # === it "does not allow target attribute"

  it "appends to rel tag if specified" do
    input = %[
      <a href="/a">a</a>
      <a href="/b" target="_blank" rel="archives">b</a>
    ]
    expect = %[
      <a href="/a">a</a>
      <a href="/b" target="_blank" rel="archives nofollow noopener noreferrer">b</a>
    ]
    actual = SPEC_A_TAG.new(input, __DIR__).to_html
    should_eq actual, expect
  end # === it "appends to rel tag if specified"
end # === desc "a tag"


