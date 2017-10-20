
class Example_00_Quick
  include DA_HTML
end # === class HTML

describe "Example_00_Quick" do
  it "renders html" do
    actual = Example_00_Quick.to_html {
      p {
        "hello"
      }
    }

    should_eq actual, %(
      <p>hello</p>
    )
  end
end # === desc "Example_00_Intro"
