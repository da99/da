
describe "Javascript.to_javascript negative" do

  it "renders variable if negative" do
    html = <<-HTML
      <html> <head></head> <body>
          <template id="my_template">
            <negative data.x> <p><=x></p> </negative>
          </template>
        </body> </html>
    HTML
    doc = DA_HTML.to_tags(html)
    actual = DA.strip_each_line(DA_HTML::Javascript.to_javascript(doc))
    expected = DA.strip_each_line(
      %[
        function my_template(data) {
          let io = "";
          if (data.x < 0) {
            io += "<p>";
            io += x.toString();
            io += "</p>";
          } // if < 0
          return io;
        } // function
      ]
    )
    assert actual == expected
  end # === it
end # === desc "Javascript.to_javascript each"
