


describe ":basics" do
  it "renders p tag" do
    actual = Basic_Spec_HTML.render { p { "hello" } }
    should_eq actual, "<p>hello</p>"
  end # === it "renders p tag"

  it "renders tags within tags" do
    actual = render {
      div {
        p { span { "hello"} }
        p { }
      }
    }

    should_eq actual, "<div><p><span>hello</span></p><p></p></div>"
  end # === it "renders tags within tags"

  it "renders doctype" do
    actual = render {
      doctype!
      html {
        head {
          title "Hello"
        }
        body {
          p { "done" }
        }
      }
    }

    should_eq actual, strip(%(
    <!DOCTYPE html>
    <html>
      <head>
        <title>Hello</title>
      </head>
      <body><p>done</p></body>
    </html>
                            ))
  end # === it "renders doctype"

  {% for x in %w(div p span) %}
    it "renders id and classes on {{x.id}}" do
      actual = render {
        {{x.id}}("#pepper", "red", "hot") { "spicy" }
      }

      should_eq actual, %{<{{x.id}} id="pepper" class="red hot">spicy</{{x.id}}>}
    end # === it "renders id and classes"
  {% end %}


end # === desc ":basics"
