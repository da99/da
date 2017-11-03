
class SPEC_IT_WORKS
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

  finish_def_html!
end # === class Spec_Parser

describe DA_HTML::Parser do
  input_file = "/input.html"
  expected   = File.read("#{__DIR__}/expected.html")

  it "works" do
    actual = SPEC_IT_WORKS.new(input_file, __DIR__).to_html
    should_eq strip(actual), strip(expected)
  end # === it "#{x.gsub(".", " ")}"
end # === describe
