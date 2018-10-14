
describe "DA_HTML::To_HTML.to_html" do
  it "prints an DA_HTML::Document" do
    html     = %[ <html><body><p>hello</p></body></html> ]
    expected = %[<!doctype html>\n<html lang="en"><head></head><body><p>hello</p></body></html>]
    doc      = DA_HTML.to_document(html)

    actual = DA_HTML::To_HTML.to_html(doc)
    assert actual == expected
  end # === it
end # === desc "DA_HTML::To_HTML"
