
class TO_DA_HTML

  include DA_HTML::Printer

  class Parser

    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "text!"
        x
      else
        allow_body_tag(x, id: DA_HTML::SEGMENT_ATTR_ID)
      end
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

  it "produces a new instruction for each new line of 'text'" do
    html = %[
      <p id="main">
        a
        b
        c
      </p>
      <div id="second">
        multi
        line
        string
      </div>
    ]
    expect = %[
      open-tag p
      attr id main
      text 
      text         a
      text         b
      text         c
      text       
      close-tag p
      open-tag div
      attr id second
      text 
      text         multi
      text         line
      text         string
      text       
      close-tag div
    ].strip.split("\n").map(&.lstrip).join("\n")

    TO_DA_HTML.new(html, __DIR__).to_da_html.should eq(expect)
  end # === it "produces a new instruction for each new line of 'text'"

  it "produces a String that can be consumed by a Printer" do
    html = %[
      <p id="main">
        a
        b
        c
      </p>
      <div id="second">
        multi
        line
        string
      </div>
    ]

    da_html  = TO_DA_HTML.new(html, __DIR__).to_da_html

    should_eq(
      TO_DA_HTML.new_from_da_html(da_html, __DIR__).to_html,
      html
    )
  end # === it "produces a String that can be consumed by a Printer"

end # === desc ":to_da_html"

