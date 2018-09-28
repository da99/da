
describe DA_HTML::Document do
  it "produces an array of Text and Tag" do
    html = %[ <html><body>a</body></html> ]

    doc = DA_HTML::Document.new(html)
    assert doc.nodes.class == Array(DA_HTML::Node)
  end # === it
end # === desc "Document"
