

describe ":template" do

  it "renders as a script tag" do
    actual = render {
      template("#row") { p { "hello" } }
    }

    should_eq actual, %(
    <script id="row" type="text/da-html-template">
      &#x3c;p&#x3e;hello&#x3c;/p&#x3e;
    </script>
    ).split("\n").map { |x| x.strip }.join
  end # === it "renders as a script tag"

  it "does not escape template vars returned from a block" do
    actual = render {
      template("#row") { p { var("hello") } }
    }

    should_eq actual, strip_each_line(
      %(
        <script id="row" type="text/da-html-template">
          &#x3c;p&#x3e;{{hello}}&#x3c;/p&#x3e;
        </script>
      )
    )
  end # === it "does not escape vars"

  it "does not escape template vars used in text(...)" do
    actual = render {
      template("#row") { p {
        text "{{hello1}}", var("hello2")
      } }
    }

    should_eq actual, strip_each_line(
      %(
        <script id="row" type="text/da-html-template">
          &#x3c;p&#x3e;&#x26;#123;&#x26;#123;hello1&#x26;#125;&#x26;#125;{{hello2}}&#x3c;/p&#x3e;
        </script>
      )
    )
  end # === it "does not escape vars"

  it "does not escape a var each" do
    actual = render {
      template("#row") {
        var_each("members") {
          p { var("name") }
        }
      }
    }

    should_eq actual, strip_each_line(
      %(
        <script id="row" type="text/da-html-template">
          {{#members}}
            &#x3c;p&#x3e;{{name}}&#x3c;/p&#x3e;
          {{/members}}
        </script>
      )
    )
  end # === it "does not escape a var each"

end # === desc ":template"
