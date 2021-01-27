
require "colorize"

module DA_SPEC

  @@pattern : String | Symbol | Regex | Nil = nil

  def self.print_pass
    print "✓".colorize.green
  end

  def self.print_fail
    print "✗".colorize.red, '\n'
  end # === def print_fail

  def self.blok
    yield
  end # def

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

  def self.matches?(full_name)
    return false if skip_all?

    target = pattern
    case target
    when String
      full_name[target]?
    when Regex
      target =~ full_name
    when Nil
      true
    else
      false
    end
  end # === def self.matches?

  class Describe

    class_getter names = Deque(String).new
    class_getter asserts = Deque(String).new

  end # === class Describe

  def examine(*args)
    args.each { |pair|
      puts "  #{pair.first.colorize.mode(:bold)}: #{pair.last.inspect}"
    }
  end # def

  def describe(*args, &blok)
    return if DA_SPEC.skip_all?
    name = args.map { |x| x.to_s.strip }.join(' ')
    print name.colorize.bold, ":", "\n"
    Describe.names.push name
    yield
    Describe.names.pop
  end # === def describe

  def it(name : String)
    full_name = [Describe.names.last, name.strip].join(' ')
    Describe.names.push name
    if DA_SPEC.matches?(full_name)
      beginning_assert_count = Describe.asserts.size
      print "- ", name, ": "
      begin
        yield
      rescue ex
        DA_SPEC.print_fail
        puts "  #{ex.class.to_s}: #{ex.message.colorize.bold}"
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
        DA_SPEC.print_fail
        STDERR.puts "  No assertions were specified.".colorize.yellow.bold
        exit 1
      end

      print '\n'
    end

    Describe.names.pop
  end # === def

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
      DA_SPEC.print_pass
    else
      DA_SPEC.print_fail
      puts "  #{__LINE__.colorize.bold}: #{__FILE__}"
      puts "  #{%origin.colorize.bold} -> #{%result.inspect.colorize.red.bold}"
      examine({ {{func_call.receiver.stringify}}, %a}, { {{func_call.args.first.stringify}}, %b})
      exit 1
    end
  end # === macro assert

  def assert_raises(error_class, msg : Nil | String | Regex = nil)
    Describe.asserts.push(error_class.to_s)
    begin
      yield
      DA_SPEC.print_fail
      examine({"Expected", error_class.name}, {"Actual", "[none]"})
      exit 1
    rescue e
      case
      when e.class == error_class && !msg
        DA_SPEC.print_pass
      when e.class == error_class && msg.is_a?(String) && e.message == msg
        DA_SPEC.print_pass
      when e.class == error_class && msg.is_a?(Regex) && e.message =~ msg
        DA_SPEC.print_pass
      else
        DA_SPEC.print_fail
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

end # === module DA_SPEC

at_exit {
  if DA_SPEC::Describe.asserts.empty?
    STDERR.puts "!!! No assertions were run.".colorize.yellow.bold
    exit 1
  end
}

