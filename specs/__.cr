
require "da_spec"
require "inspect_bang"
require "../src/da_html"

macro strip(str)
  %result = {{str}}
  case %result
  when String
    %result.strip.split("\n").map { |x| x.strip }.join
  else
    %result
  end
end

DA_SPEC.pattern(ARGV.join(" ")) unless ARGV.empty?
extend DA_SPEC

require "./compiler/Each_Node"
require "./compiler/Document"
# require "../examples/*"
# require "./dsl/*"


