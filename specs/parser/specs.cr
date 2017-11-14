
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

struct SPECS_PARSER
  include DA_HTML::Printer

  struct Parser
    include DA_HTML::Parser
    def allow(name : String, node : XML::Node)
      case name
      when "text!"
        node
      when "doctype!", "html"
        allow_document_tag(node)
      when "head", "body"
        allow_html_tag(node)
      when "title"
        allow_head_tag(node)
      when "link"
        allow_head_tag(node, href: /([\/a-z0-9\_\-\.])+/)
      when "p", "div"
        allow_body_tag(node)
      end
    end # === def self.parse
  end # === struct Parser
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
    it "#{name}" do
      actual = SPECS_PARSER.new(File.read(input), x).to_html
      should_eq strip(actual), strip(File.read(expect))
    end
  }
end # === desc "parser"
