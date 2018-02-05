

describe ":template" do

  it "renders as a script tag" do
    actual = DA_HTML.to_html {
      template("#row") { p { "hello" } }
    }

    should_eq actual, %(
    <script id="row" type="text/da-html-template">
      &#x3c;p&#x3e;hello&#x3c;/p&#x3e;
    </script>
    ).split("\n").map { |x| x.strip }.join
  end # === it "renders as a script tag"

  it "does not escape template vars returned from a block" do
    actual = DA_HTML.to_html {
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
    actual = DA_HTML.to_html {
      template("#row") {
        p { text "{{hello1}}", var("hello2") } 
      }
    }

    should_eq actual, strip_each_line(
      %(
        <script id="row" type="text/da-html-template">
          &#x3c;p&#x3e;&#x26;#x7b;&#x26;#x7b;hello1&#x26;#x7d;&#x26;#x7d;{{hello2}}&#x3c;/p&#x3e;
        </script>
      )
    )
  end # === it "does not escape vars"

  it "does not escape a var each" do
    actual = DA_HTML.to_html {
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

  it "renders an inverted section" do
    actual = DA_HTML.to_html {
      template("#row") {
        var_not("members") {
          p { "no members" }
        }
      }
    }

    should_eq actual, strip_each_line(
      %(
        <script id="row" type="text/da-html-template">
          {{^members}}
            &#x3c;p&#x3e;no members&#x3c;/p&#x3e;
          {{/members}}
        </script>
      )
    )
  end # === it "renders an inverted section"

  it "renders double quotation marks" do
    actual = DA_HTML.to_html {
      template("#row") {
        p("#main") { "no members" }
      }
    }

    should_eq actual, strip_each_line(
      %(
        <script id="row" type="text/da-html-template">
            &#x3c;p id="main"&#x3e;no members&#x3c;/p&#x3e;
        </script>
      )
    )
  end # === it "renders double quotation marks"

  it "double escapes ampersands" do
    actual = DA_HTML.to_html {
      template("#row") {
        p { "& & &" }
      }
    }

    should_eq actual, strip_each_line(
      %(
        <script id="row" type="text/da-html-template">
            &#x3c;p&#x3e;&#x26;#x26; &#x26;#x26; &#x26;#x26;&#x3c;/p&#x3e;
        </script>
      )
    )
  end # === it "double escapes ampersands"

end # === desc ":template"

