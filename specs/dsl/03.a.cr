
describe "a tag" do
  it "throws javascript :href values" do
    actual = DA_HTML.to_html {
      a(href: "javascript://a") { "my page" }
    }
    assert actual == %(<a href="#invalid_url">my page</a>)
  end # === it "sanitizes javascript :href values"

  it "allows :id attribute" do
    actual = DA_HTML.to_html {
      a("#main", href: "/page") { "the page" }
    }
    assert actual == %(<a id="main" href="/page">the page</a>)
  end # === it "allows :id attribute"
end # === desc "a tag"
