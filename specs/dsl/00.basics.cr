

describe ":basics" do

  it "renders doctype" do
    actual = DA_HTML.to_html {
      doctype!
      html {
        head {
          title { "Hello" }
        }
        body {
          p { "done" }
        }
      }
    }

    assert actual == strip(%(
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>Hello</title>
      </head>
      <body><p>done</p></body>
    </html>
    ))
  end # === it "renders doctype"

  it "renders p tag" do
    actual = DA_HTML.to_html { p { "hello" } }
    assert actual == "<p>hello</p>"
  end # === it "renders p tag"

  it "renders tags within tags" do
    actual = DA_HTML.to_html {
      div {
        p { span { "hello"} }
        p { }
      }
    }

    assert actual == "<div><p><span>hello</span></p><p></p></div>"
  end # === it "renders tags within tags"

  {% for x in %w(div p span) %}
    it "renders id and classes on {{x.id}}" do
      actual = DA_HTML.to_html {
        {{x.id}}("#pepper.red.hot") { "spicy" }
      }

      assert actual == %{<{{x.id}} id="pepper" class="red hot">spicy</{{x.id}}>}
    end # === it "renders id and classes"
  {% end %}

  it "escapes text from a yielded block" do
    actual = DA_HTML.to_html {
      span { "yo & yo" }
    }
    assert actual == %[<span>yo &#x26; yo</span>]
  end # === it "escapes text from a yielded block"

end # === desc ":basics"
