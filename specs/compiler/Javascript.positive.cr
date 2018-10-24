
describe "Javascript.to_javascript positive" do

  it "renders variable if positive" do
    html = <<-HTML
      <html> <head></head> <body>
          <template id="my_template">
            <positive data.x> <p><=x></p> </positive>
          </template>
        </body> </html>
    HTML
    doc = DA_HTML.to_tags(html)
    actual = DA.strip_each_line(DA_HTML::Javascript.to_javascript(doc))
    expected = DA.strip_each_line(
      %[
        function my_template(data) {
          let io = "";
          if (data.x === 0) {
            io += "<p>";
            io += x.toString();
            io += "</p>";
          } // if === 0
          return io;
        } // function
      ]
    )
    assert actual == expected
  end # === it
end # === desc
