
require "da"
require "da_spec"
require "../src/da_html"

macro strip(str)
  %result = {{str}}
  if %result.is_a?(IO::Memory)
    %result = %result.to_s
  end

  case %result
  when String
    %result.strip.split("\n").map { |x| x.strip }.join
  else
    %result
  end
end

DA_Spec.pattern(ARGV.join(" ")) unless ARGV.empty?

module DA_Spec
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
end # === module DA_Spec

extend DA_Spec

require "./main/*"


