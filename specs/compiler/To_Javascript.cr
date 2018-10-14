

describe "DA_HTML::To_Javascript.to_javascript" do

  it "turns template tags to Javascript functions" do
    html = <<-HTML
      <html>
        <head></head>
        <body>
          <template id="my_template"> <p>abc</p> </template>
        </body>
      </html>
    HTML
    doc = DA_HTML.to_document(html)
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
