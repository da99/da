
require "spec"
require "../src/da_html"


macro should_eq(actual, expected)
  strip({{actual}}).should eq(strip( {{expected}} ))
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
require "./parser/specs"
require "../examples/00.quick"


