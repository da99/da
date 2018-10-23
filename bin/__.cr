
require "../src/da_html"

html = File.read("extra/sample.html")

module DA_HTML

  extend self

  module Cleaner
    def clean(x) : Tag | Symbol
      raise Exception.new("Not implemented: #{self.to_s}.clean")
    end
  end # === struct Cleaner

end # === module DA_HTML

module Upcase_HREF
  extend self
  def clean(t)
    case
    when t.is_a?(DA_HTML::Tag) && t.tag_name == "a"
      t.attributes({"href"=>"/UPCASE"})
      t.tag_text "#{t.tag_text} done"
      return t
    end
    return t
  end
end # === class Upcase_HREF

module Clean_First_Text
  extend self
  def clean(t)
    case
    when t.is_a?(DA_HTML::Text) && t.index == 0
      t.tag_text t.tag_text.lstrip
      return t
    end
    return t
  end # === def
end # === module Clean_First_Text

doc = Deque(Node).new(html)
doc.map_walk! { |n|
  Upcase_HREF.clean(
    Clean_First_Text.clean(n)
  )
}

# puts da_html.javascript
puts doc.html
puts doc.raw
# puts doc.crystal
# puts doc.javascript
File.write("tmp/html.cr", doc.crystal)
Process.exec("crystal", "build tmp/html.cr -o tmp/html.cr.run".split)
# File.write(
#   "tmp/a.js",
#   <<-JS
#     #{js_template.javascript}
#     {
#       let data = {
#         persons : [{name: "Phil", addresses: [{location: "Mongo City", planet: "Main Mongo"}, {location: "Star City", planet: "Earth"}]}],
#         minus_3: -3,
#         positive: 5,
#         negative: -5,
#         zero: 0,
#         empty_array: [],
#         };
#       let s = template(data);
#       // console.log(data);
#       console.log(s);
#     }
#   JS
# )
# Process.exec("node", "tmp/a.js".split)

