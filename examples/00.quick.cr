

describe "Example_00_Quick" do

  it "renders html" do
    actual = DA_HTML.to_html {
      p {
        strong { "hello" }
      }
    }
    assert actual == "<p><strong>hello</strong></p>"
  end

end # === desc "Example_00_Quick"

