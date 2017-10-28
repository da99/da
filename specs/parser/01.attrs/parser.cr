
class SPEC_02_ATTRS
  include DA_HTML::Parser
  def_tags :html , :head , :title , :body , :p
  def_tag :css do |node|
    @io << %(<link href="/main.css" rel="stylesheet">)
    return false
  end

  def_tag :js do |node|
    @io << %(<script src="/main.js" type="application/javascript"></script>)
    return false
  end

  def_to_html!
end # === class Spec_Parser

describe DA_HTML::Parser do
  input_file = "#{__DIR__}/input.html"
  expected   = File.read("#{__DIR__}/expected.html")

  it "works" do
    actual = SPEC_02_ATTRS.new(input_file).to_html
    should_eq strip(actual), strip(expected)
  end # === it "#{x.gsub(".", " ")}"
end # === describe
