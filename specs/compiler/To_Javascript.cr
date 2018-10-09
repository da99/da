

describe "DA_HTML::To_Javascript.to_javascript" do

  it "turns script tags to javascript tags to a Javascript code" do
    html = <<-HTML
      <html>
        <head>
        </head>
        <body>
          <script id="my_template">
            <p>abc</p>
          </script>
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

  it "renders: for coll as x" do
    html = <<-HTML
      <html>
        <head></head>
        <body>
          <script id="my_template">
            <each coll as x> <p><=x></p> </each>
          </script>
        </body>
      </html>
    HTML
    doc = DA_HTML::Document.new(html)
    actual = DA.strip_each_line(DA_HTML::To_Javascript.to_javascript(doc))
    expected = DA.strip_each_line(
      %[
        function my_template(data) {
          let io = "";
          for (let _coll__i = 0, _coll__len = coll.length; _coll__i < _coll__len; ++_coll__i) {
            let x = coll[_coll__i];
            io += "<p>";
            io += x.toString();
            io += "</p>";
          }
          return io;
        }
      ]
    )
    assert actual == expected
  end # === it

end # === desc "DA_HTML::To_Javascript.to_javascript"
