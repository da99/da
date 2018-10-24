
describe "Javascript.to_javascript not-empty" do

  it "renders length variable if not-empty" do
    html = <<-HTML
      <html> <head></head> <body>
          <template id="my_template">
            <not-empty data.x> <p>is not empty</p> </not-empty>
          </template>
        </body> </html>
    HTML
    doc = DA_HTML.to_tags(html)
    actual = DA.strip_each_line(DA_HTML::Javascript.to_javascript(doc))
    expected = DA.strip_each_line(
      %[
        function my_template(data) {
          let io = "";
          if (data.x.length > 0) {
            io += "<p>";
            io += "is not empty";
            io += "</p>";
          } // if length > 0
          return io;
        } // function
      ]
    )
    assert actual == expected
  end # === it
end # === desc
