
require "../../src/da_html/parser"

{% begin %}
  {% files = system("find specs/parser -mindepth 2 -type f -name specs.cr").split("\n").reject { |x| x.strip.empty? } %}
  {% if files.empty? %}
    {% raise "No specs found in specs/parser" %}
  {% end %}
  {% for x in files %}
    require "../../{{x.id}}"
  {% end %}
{% end %}

class SPECS_PARSER
  include DA_HTML::Parser

  def_tags :html , :head , :title , :body , :p
  finish_def_html!
end # === class SPECS_PARSER

describe "Parser" do
  Dir.glob("specs/parser/*").each { |x|
    expect = File.join(x, "expect.html")
    input  = File.join(x, "input.html")
    specs  = File.join(x, "specs.cr")
    name   = File.basename(x).gsub(/_|-/, " ")
    next unless Dir.exists?(x)
    next unless File.exists?(expect)
    next unless File.exists?(input)
    next if File.exists?(specs)
    puts input
    it "#{name}" do
      actual = SPECS_PARSER.new("input.html", x).to_html
      should_eq strip(actual), strip(File.read(expect))
    end
  }
end # === desc "parser"
