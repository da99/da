
describe "a tag" do

  it "raises DA_HTML::HTML_Attribute::Invalid_Value on javascript :href values" do
    assert_raises(DA_HTML::HTML_Attribute::Invalid_Value) {
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

end # === desc "a tag"
