
require "colorize"

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

    full_name = a.full_name
    target = pattern
    case target
    when String
      a.full_name[target]?
    when Regex
      target =~ a.full_name
    when Nil
      true
    else
      false
    end
  end # === def self.matches?

  class Describe

    class_getter names = Deque(String).new
    class_getter asserts = Deque(String).new

    getter name : String

    def initialize(*args)
      @name = args.map(&.to_s).join(" ")
      @already_printed_header = false
    end # === def initalize

    def it(name : String, file = __FILE__, line = __LINE__)
      x = It.new(name, file: file, line: line)
      Describe.names.push x.name
      if DA_SPEC.matches?(x)
        beginning_assert_count = Describe.asserts.size
        print "- ", x.name, ": "
        begin
          with x yield
        rescue ex
          x.print_fail
          puts "  #{ex.class.to_s}: #{ex.message.colorize.mode(:bold)}"
          line_count = 0
          ex.backtrace.each { |line|
            print "  "
            puts line
            line_count += 1
            break if line_count > 15
          }
          exit 1
        end
        ending_assert_count = Describe.asserts.size
        if beginning_assert_count == ending_assert_count
          raise Exception.new("No assertions for 'it'.")
        end
        print '\n'
      end
      Describe.names.pop
    end # === def it

  end # === class Describe

  class It

    getter? header_written : Bool = false
    getter name : String
    getter file : String
    getter line : Int32

    def initialize(@name, @file, @line)
    end # === def initialize

    def full_name
      Describe.names.map(&.strip).join(' ')
    end # === def full_name

    def print_pass
      print "✔".colorize(:green)
    end

    def print_fail
      print "✗".colorize(:red), '\n'
    end # === def print_fail

    def assert_raises(error_class, msg : Nil | String | Regex = nil)
      Describe.asserts.push(error_class.to_s)
      begin
        yield
        print_fail
        examine({"Expected", error_class.name}, {"Actual", "[none]"})
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
        e
      end
    end # === def assert_raises


  end # === class It

  def describe(*args)
    return if DA_SPEC.skip_all?
    d = Describe.new(*args)
    print d.name.colorize.mode(:bold), ":", "\n"
    Describe.names.push d.name
    with d yield
    Describe.names.pop
    d
  end # === def describe

  def examine(*args)
    args.each { |pair|
      puts "  #{pair.first.colorize.mode(:bold)}: #{pair.last.inspect}"
    }
  end # def

  macro assert(func_call)
    %origin   = {{func_call.stringify}}
    %a        = {{func_call.receiver}}
    %b        = {{func_call.args.first}}
    %has_err  = nil
    %result   = %a.{{func_call.name}}(%b)
    %a_string = %a.inspect
    %b_string = %b.inspect

    Describe.asserts.push %origin

    if %result
      print_pass
    else
      print_fail
      puts "  #{line.colorize.mode(:bold)}: #{file}"
      puts "  #{%origin.colorize.mode(:bold)} -> #{%result.inspect.colorize(:red).mode(:bold)}"
      examine({"A", %a}, {"B", %b})
      exit 1
    end
  end # === macro assert

end # === module DA_SPEC

at_exit {
  if DA_SPEC::Describe.asserts.empty?
    STDERR.puts "!!! No assertions were run."
    exit 1
  end
}

