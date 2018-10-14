
describe DA_HTML::Document do

  it "produces an array of Text and Tag" do
    html = %[ <html><body>a</body></html> ]

    doc = DA_HTML.to_document(html)
    assert doc.class == Deque(DA_HTML::Node)
  end # === it

end # === desc "Document"
