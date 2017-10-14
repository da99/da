

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

end # === desc ":template"
