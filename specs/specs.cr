
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

extend DA_SPEC

require "../examples/*"
require "./dsl/*"


