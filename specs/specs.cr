
require "da_spec"
require "inspect_bang"
require "../src/da_html"

macro strip(str)
  {{str}}.strip.split("\n").map { |x| x.strip }.join
end

extend DA_SPEC

require "../examples/*"
require "./dsl/00.basics"
require "./dsl/01.customize"
require "./dsl/02.attrs"
require "./dsl/03.a"


