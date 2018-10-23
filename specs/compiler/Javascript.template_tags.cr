
describe "Javascript.template_tags" do
  it "returns a Document of template tags" do
    html = <<-HTML
    <html>
      <head></head>
      <body>
        <template id="t1"></template>
        <div>
          <template id="t2"></template>
          <p>
            <template id="t3"></template>
          </p>
        <div>
      </body>
    </html>
    HTML

    doc = DA_HTML.to_tags(html)
    actual = DA_HTML::Javascript.template_tags(doc).map { |n|
      case n
      when DA_HTML::Tag
        n.attributes["id"]
      end
    }.compact
    assert actual == "t1 t2 t3".split
  end # === it
end # === desc "Javascript.template_tags"
