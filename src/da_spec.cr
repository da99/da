
require "colorize"
require "terminal_table"

module DA_SPEC

  @@pattern : String | Symbol | Regex | Nil = nil

  def self.pattern
    @@pattern
  end

  def self.pattern(r : Regex | String | Symbol | Nil)
    @@pattern = r
  end # === def self.patter

  def self.skip_all!
    @@pattern = :skip_all
  end # === def self.skip!

  def self.skip_all?
    @@pattern == :skip_all
  end

  def self.matches?(a)
    return false if skip_all?

    p = pattern
    case p
    when String
      a.full_name.index(p)
    when Regex
      p =~ a.full_name
    when Nil
      true
    else
      false
    end
  end # === def self.matches?

  class Describe

    getter name : String

    def initialize(*args)
      @name = args.map(&.to_s).join(" ")
      @already_printed_header = false
    end # === def initalize

    def it(name : String)
      x = It.new(self, name)
      if DA_SPEC.matches?(x)
        begin
          with x yield
        rescue ex
          puts_header
          x.print_fail "(", ex.class.to_s, ") ", ex.message.colorize.mode(:bold)
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
      [@describe.name, name].compact.join(" ")
    end # === def full_name

    def print_pass
      print "- ", name.colorize(:green), "\n"
    end

    def print_fail(*args)
      print "- ", name.colorize(:red), ": ", *args
      print "\n"
    end # === def print_fail

    def assert_raises(error_class, msg : Nil | String | Regex = nil)
      describe.puts_header
      begin
        yield
        print_fail
        examine({"Expected: ", error_class.name}, {"Actual: ", "[none]"})
        exit 1
      rescue e
        case
        when e.class == error_class && !msg
          print_pass
        when e.class == error_class && msg.is_a?(String) && e.message == msg
          print_pass
        when e.class == error_class && msg.is_a?(Regex) && e.message =~ msg
          print_pass
        else
          print_fail
          if msg
            examine({"Expected: ", error_class.name + ": " + msg.inspect}, {"Actual: ", e.class.name + ": " + e.message.inspect})
          else
            examine({"Expected: ", error_class}, {"Actual: ", e.class})
          end
          exit 1
        end
      end
    end # === def assert_raises


  end # === class It

  def describe(*args)
    return if DA_SPEC.skip_all?
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
    %origin   = {{func_call.stringify}}
    %a        = {{func_call.receiver}}
    %b        = {{func_call.args.first}}
    %has_err  = nil
    %result   = %a.{{func_call.name}}(%b)
    %a_string = %a.inspect
    %b_string = %b.inspect

    describe.puts_header
    if %result
      print_pass
    else
      print_fail("#{%origin} -> #{%result.inspect}".colorize.mode(:bold))
      examine({"A", %a}, {"B", %b})
      exit 1
    end
  end # === macro assert

end # === module DA_SPEC

