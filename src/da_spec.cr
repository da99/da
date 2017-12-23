
require "colorize"

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
        with x yield
      end
    end # === def it

    def puts_header
      unless @already_printed_header
        print name.colorize.mode(:bold)
        print ":\n"
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

  macro examine(key, val)
    %as_string = {{val}}.inspect
    %key       = {{key}}
    %val       = {{val}}
    case %val
    when String
      puts "#{%key}: (String)\n============================\n#{%val}\n============================\n"
    else
      puts "#{%key}: #{%as_string}"
    end
  end

  macro assert(func_call)
    %origin = %<{{func_call}}>
    %a = {{func_call.receiver}}
    %b = {{func_call.args.first}}
    %result = %a.{{func_call.name}}(%b)
    %a_string = %a.inspect
    %b_string = %b.inspect

    describe.puts_header
    if %result
      print "- ", name.colorize(:green), "\n"
    else
      print(name.colorize(:red), ": ", "#{%origin} -> #{%result.inspect}".colorize.mode(:bold), "\n")
      examine("A", %a)
      examine("B", %b)
      exit 1
    end

  end # === macro desc

end # === module DA_SPEC

