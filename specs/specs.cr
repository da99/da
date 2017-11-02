
require "spec"
require "../src/da_html"


macro should_eq(actual, expected)
  {{actual}}.should eq(strip( {{expected}} ))
end # === macro should_eq

macro strip(str)
  ({{str}} || "").strip.gsub("\n", "").gsub(/>\s+</, "><")
end

macro render(&blok)
  Basic_Spec_HTML.render {
    {{blok.body}}
  }
end

macro strip_each_line(str)
  {{str}}.split("\n").map { |x| x.strip }.join
end

# === Parser
require "../src/da_html/parser"
{% begin %}
  {% files = system("find specs/parser -mindepth 2 -type f -name specs.cr").split("\n").reject { |x| x.strip.empty? } %}
  {% if files.empty? %}
    {% raise "No specs found in specs/parser" %}
  {% end %}
  {% for x in files %}
    require "../{{x.id}}"
  {% end %}
{% end %}


# === DSL
require "../src/da_html/dsl"

class Basic_Spec_HTML
  include DA_HTML::DSL::DOCTYPE
  include DA_HTML::DSL::HTML
  include DA_HTML::DSL::HEAD
  include DA_HTML::DSL::TITLE
  include DA_HTML::DSL::BODY
  include DA_HTML::DSL::SPAN
  include DA_HTML::DSL::P
  include DA_HTML::DSL::DIV
  include DA_HTML::DSL::TEMPLATE
  include DA_HTML::DSL::TEXT

  getter :io
  @io : DA_HTML::DSL::INPUT_OUTPUT | DA_HTML::DSL::TEMPLATE::INPUT_OUTPUT
  def initialize
    @io = DA_HTML::DSL::INPUT_OUTPUT.new
  end # === def initalize

  def self.render
    h = new
    with h yield
    h.io.to_html
  end

  def to_html
    @io.to_html
  end # === def to_html
end # === class HTML
require "../examples/*"
require "./dsl/*"

