
require "../../src/da_html/parser"

class Spec_Parser
  include DA_HTML::Parser
  def_tag :html
  def_tag :head
  def_tag :title
  def_tag :body
  def_tag :p
  def_tag :css do
    render do |node|
      @io << %(<link href="/main.css" rel="stylesheet">)
      return false
    end
  end
  def_tag :js do
    render do |node|
      @io << %(<script src="/main.js" type="application/javascript"></script>)
      return false
    end
  end
end # === class Spec_Parser

describe "DA_HTML::Parser" do
  Dir.glob("specs/parser/*/").each do |x|
    test_name  = File.basename(x).gsub(/^\d+|\./, " ").strip
    input_file = "#{x}input.html"
    expected   = File.read("#{x}expected.html")

    it test_name do
      actual = Spec_Parser.new(input_file).to_html
      should_eq strip(actual), strip(expected)
    end # === it "#{x.gsub(".", " ")}"
  end
end # === desc "#{File.basename x}"
