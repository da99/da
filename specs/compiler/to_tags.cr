
describe "DA_HTML.to_tags" do

  it "returns a Deque of Text, Tag, and Comment" do
    html = %[ <html><body>a</body></html> ]

    doc = DA_HTML.to_tags(html)
    assert doc.class == Deque(DA_HTML::Node)
  end # === it

  it "returns a Deque of Nodes" do
    raw = <<-HTML
       <html>
         <head></head>
         <body><p>Hello</p></body>
       </html>
    HTML

    doc = DA_HTML.to_tags(raw)
    actual = doc.is_a?(Deque(DA_HTML::Node))
    assert actual == true
  end # === it

end # === desc "Document"
