

describe "DA_HTML::To_Javascript.to_javascript" do

  it "turns script tags to javascript tags to a Javascript code" do
    html = <<-HTML
      <html>
        <head>
        </head>
        <body>
          <template id="my_template">
            <p>abc</p>
          </template>
        </body>
      </html>
    HTML
    doc = DA_HTML::Document.new(html)
    actual = DA.strip_each_line(DA_HTML::To_Javascript.to_javascript(doc))
    expected = DA.strip_each_line(%[
        function my_template(data) {
          let io = "";
          io += "<p>";
          io += "abc";
          io += "</p>";
          return io;
        }
    ])

    assert actual == expected
  end # === it

end # === desc "DA_HTML::To_Javascript.to_javascript"
