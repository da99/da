
describe "a tag" do

  it "raises DA_HTML::Attribute::Invalid_Value on javascript :href values" do
    assert_raises(DA_HTML::Attribute::Invalid_Value) {
      DA_HTML.to_html {
        a(href("javascript://a")) { "my page" }
      }
    }
  end # === it "sanitizes javascript :href values"

  it "allows :id attribute" do
    actual = DA_HTML.to_html {
      a("#main", href("/page")) { "the page" }
    }
    assert actual == %(<a id="main" href="/page" rel="nofollow noopener noreferrer">the page</a>)
  end # === it "allows :id attribute"

  {% for x in %w[nofollow noreferrer noopener] %}
    it "rel=\"{{x.id}}\"" do
      actual = DA_HTML.to_html {
        a("#main", href("/page")) { "the page" }
      }
      assert actual == %[
        <a id="main" href="/page" rel="nofollow noopener noreferrer">the page</a>
      ].strip
    end # === it "rel=\"{{x.id}}\""
  {% end %}

  it "adds rel=\"nofollow noopener noreferrer\" when target attr is used" do
    actual = DA_HTML.to_html {
      a(href("/a")) { "a" }
      a(href("/b"), target("_blank")) { "b" }
    }
    expect = %[
      <a href="/a" rel="nofollow noopener noreferrer">a</a><a href="/b" target="_blank" rel="nofollow noopener noreferrer">b</a>
    ].strip

    assert actual == expect
  end # === it "does not allow target attribute"

  it "raises DA_HTML::Attribute::Invalid_Value if rel is an unknown value" do
    msg = assert_raises(DA_HTML::Attribute::Invalid_Value) {
      actual = DA_HTML.to_html {
        a(href("/a")) { "a" }
        a(href("/b"), target("_blank"), rel("archives")) { "b" }
      }
    }.message || ""
    assert msg["archives"]? == "archives"
  end # === it "appends to rel tag if specified"

end # === desc "a tag"
