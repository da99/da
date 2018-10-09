
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

module DA_SPEC
  def examine(*args)
    all_strings = args.all? { |pair| pair.last.is_a?(String) }
    puts "================================"
    args.each { |x|
      puts x.first
      if all_strings
        puts x.last
      else
        puts x.last.inspect
      end
      puts "================================"
    }
  end
end # === module DA_SPEC

extend DA_SPEC

require "./compiler/Each_Node"
require "./compiler/Document"
require "./compiler/To_HTML"
require "./compiler/To_Javascript"
require "./compiler/To_Javascript.each"
require "./compiler/To_Javascript.each-in"
# require "../examples/*"
# require "./dsl/*"


