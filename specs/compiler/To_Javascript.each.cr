
describe "To_Javascript.to_javascript each" do

  it "renders: for coll as x" do
    html = <<-HTML
      <html> <head></head> <body>
          <template id="my_template">
            <each coll as x> <p><=x></p> </each>
          </template>
        </body> </html>
    HTML
    doc = DA_HTML.to_document(html)
    actual = DA.strip_each_line(DA_HTML::To_Javascript.to_javascript(doc))
    expected = DA.strip_each_line(
      %[
        function my_template(data) {
          let io = "";
          for (let _coll__i = 0, _coll__length = coll.length; _coll__i < _coll__length; ++_coll__i) {
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
end # === desc "To_Javascript.to_javascript each"
