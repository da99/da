
class TO_DA_HTML

  include DA_HTML::Printer

  class Parser

    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      allow_body_tag(x, id: DA_HTML::SEGMENT_ATTR_ID)
    end # === def allow

  end # === class Parser

end # === class To_DA_HTML

describe ":to_da_html" do

  it "renders HTML as a String of instructions" do
    input = %[
      <p id="main">hello</p>
      <div id="second">hello</div>
    ]
    expect = strip(%[
      open-tag p
      attr id main
      text hello
      close-tag p
      open-tag div
      attr id second
      text hello
      close-tag div
    ])
    TO_DA_HTML.new(input, __DIR__).to_da_html.should eq(expect)
  end # === it "renders HTML as a String of instructions"

end # === desc ":to_da_html"
