

describe "io.write_attr" do
  it "escapes values of attributes" do
    actual = DA_HTML.to_html {
      p(hello: "<joe>") { }
    }
    assert actual == "<p hello=\"&#x3c;joe&#x3e;\"></p>"
  end # === it "escapes values of attributes"

  it "allows single attributes: <input required ...>" do
    actual = DA_HTML.to_html {
      closed_tag("input", {"maxlength", "10"}, {"required"})
    }
    assert actual == %(<input maxlength="10" required>)
  end # === it "allows single attributes: <input required ...>"
end # === desc ":attrs"

