
require "spec"
require "../src/da_html"


macro should_eq(actual, expected)
  strip({{actual}}).should eq(strip( {{expected}} ))
end # === macro should_eq

macro strip(str)
  begin
    %str = ({{str}} || "")
    if %str.index("<")
      %str.strip.gsub("\n", "").gsub(/>\s+</, "><")
    else
      %str.strip.split("\n").map(&.strip).join("\n")
    end
  end
end

macro render(&blok)
  Basic_Spec_HTML.render {
    {{blok.body}}
  }
end

macro strip_each_line(str)
  {{str}}.split("\n").map { |x| x.strip }.join
end

macro file_read!(name)
  File.read(__DIR__ + "/" + {{name}})
end # === macro file_read!

# === Parser
require "./parser/specs"
require "../examples/*"


