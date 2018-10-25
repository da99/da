
require "da"
require "da_spec"
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
    puts "================================"

    # If 2 Strings:
    if args.size == 2 && args.all? { |pair| pair.last.is_a?(String) }
      a = args.first.last
      b = args.last.last
      if a.is_a?(String) && b.is_a?(String) && !a.empty? && !b.empty?
        a = a.lines
        b = b.lines
        a.each_with_index { |x, i|
          if b[i]? == a[i]?
            puts "#{i}: #{a[i]}"
          else
            puts "#{i} a: #{a[i]}"
            puts "#{i} b: #{b[i]?}"
            return
          end
        }
        if a.size < b.size
          b[-1..(a.size-b.size)].each_with_index { |l, x| puts "b#{x + a.size}: #{l.inspect}" }
        end
        return
      end # if a, b == String
    end

    args.each { |x|
      puts x.first
      puts x.last.inspect
      puts "================================"
    }
  end
end # === module DA_SPEC

extend DA_SPEC

require "./compiler/to_tags"
require "./compiler/to_html"
require "./compiler/to_crystal"
require "./compiler/to_javascript"
require "./compiler/Javascript.template_tags"
require "./compiler/Javascript.each"
require "./compiler/Javascript.each-in"
require "./compiler/Javascript.positive"
require "./compiler/Javascript.negative"
require "./compiler/Javascript.zero"
require "./compiler/Javascript.empty"
require "./compiler/Javascript.not-empty"
# require "../examples/*"
# require "./dsl/*"


