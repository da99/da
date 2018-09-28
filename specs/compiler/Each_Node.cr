
describe "DA_HTML::Each_Node#each" do

  it "walks through each node" do
    html = %[
      <html>
        <head> <title></title> </head>
        <body> <p>text</p> </body>
      </html>
    ].split.join

    expected = ["html", "head", "title", "body", "p", "-text"]
    doc      = DA_HTML::Document.new(html)
    actual   = [] of String
    DA_HTML::Each_Node.each(doc.nodes) { |n| actual << n.tag_name }

    assert expected == actual
  end # === it

end # === desc ":walk"
