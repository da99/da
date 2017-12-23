
require "colorize"
require "terminal_table"

module DA_SPEC

  class Describe

    @@pattern : String | Regex | Nil = nil

    def self.matches?(a)
      p = pattern
      case p
      when String
        a.full_name.index(p)
      when Regex
        p =~ a.full_name
      else
        true
      end
    end # === def self.matches?

    def self.pattern
      @@pattern
    end

    def self.pattern(r : Regex | String)
      @@pattern = r
    end # === def self.patter

    getter name : String

    def initialize(*args)
      @name = args.map(&.to_s).join(" ")
      @already_printed_header = false
    end # === def initalize

    def it(name : String)
      x = It.new(self, name)
      if Describe.matches?(x)
        begin
          with x yield
        rescue ex
          puts_header
          print "- ", x.name.colorize(:red), ": (", ex.class.to_s, ") ", ex.message.colorize.mode(:bold), "\n"
          count = 0
          ex.backtrace.each { |line|
            puts line
            count += 1
            break if count > 15
          }
          exit 1
        end
      end
    end # === def it

    def puts_header
      unless @already_printed_header
        print name.colorize.mode(:bold), ":", "\n"
        @already_printed_header = true
      end
    end # === def puts_name

  end # === class Describe

  class It

    getter name : String
    getter describe : Describe

    def initialize(@describe, @name)
    end # === def initialize

    def full_name
      "#{@describe.name}: #{name}"
    end # === def full_name

  end # === class It

  def describe(*args)
    d = Describe.new(*args)
    with d yield
  end # === def describe

  def examine(*args)
    headings = [] of String
    rows = [] of String
    args.each { |pair|
      key       = pair.first
      val       = pair.last
      as_string = pair.last.inspect

      headings.push key
      rows.push as_string
    }

    t = TerminalTable.new
    t.headings = headings
    t << rows
    puts t.render
  end

  macro assert(func_call)
    %origin = %<{{func_call}}>
    %a = {{func_call.receiver}}
    %b = {{func_call.args.first}}
    %has_err = nil
    %result = %a.{{func_call.name}}(%b)
    %a_string = %a.inspect
    %b_string = %b.inspect

    describe.puts_header
    if %result
      print "- ", name.colorize(:green), "\n"
    else
      print(name.colorize(:red), ": ", "#{%origin} -> #{%result.inspect}".colorize.mode(:bold), "\n")
      examine({"A", %a}, {"B", %b})
      exit 1
    end

  end # === macro desc

end # === module DA_SPEC

