

describe "DA_HTML::To_Javascript.to_javascript" do
  it "turns script tags to javascript tags to a Javascript code" do
    html = <<-HTML
      <html>
        <head>
        </head>
        <body>
          <script id="my_template">
            <p>a</p>
          </script>
        </body>
      </html>
    HTML
    doc = DA_HTML::Document.new(html)
    actual = DA_HTML::To_Javascript.to_javascript(doc).strip
    expected = %[
        function my_template(data) {
          let io = "";
          let io += "<p>a</p>";
          return io;
        }
    ]

    if DA.development?
      puts actual
    end
    assert actual == expected
  end # === it
end # === desc "DA_HTML::To_Javascript.to_javascript"
