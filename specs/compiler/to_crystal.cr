
describe "DA_HTML.to_crystal" do

  it "prints content in Crystal tags" do
    html = <<-HTML
      <html><head></head><body>
          <crystal>
          a = 1
          </crystal>
        </body></html>
    HTML
    doc = DA_HTML.to_tags(html)
    actual = DA.strip_each_line(DA_HTML.to_crystal(doc))
    expected = DA.strip_each_line(%[ a = 1 ])

    assert actual == expected
  end # === it

  it "prints content in template/each tags" do
    html = <<-HTML
      <html><head></head><body>
          <crystal> data = [] of String </crystal>
          <template id="my_template">
            <each data.arr as x> entry </each>
          </template>
        </body></html>
    HTML
    doc = DA_HTML.to_tags(html)
    actual = DA.strip_each_line(DA_HTML.to_crystal(doc))
    expected = DA.strip_each_line(
      %[
        data = [] of String
        def my_template(data)
          data.arr.each { |x|
          }
        end
        my_template(data)
      ]
    )

    assert actual == expected
  end # === it
end # === desc "DA_HTML.to_crystal"
