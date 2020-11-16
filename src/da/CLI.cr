
module DA
  module CLI
    extend self

    @@help_was_printed = false
    @@action_was_executed = false

    DESC = [] of String

    IS_HELP = begin
                if ARGV.first? == "-h" || ARGV.first? == "help"
                  ARGV.shift
                  ARGV.join(' ')
                end # if
              end

    def bin_dir
      File.dirname(Process.executable_path)
    end # === def apps_dir

    def parse
      yield self
      exit 0 if @@help_was_printed || @@action_was_executed
    end # def

    def desc(x : String)
      is_help = IS_HELP
      case is_help
      when String
        if is_help.empty? || x[is_help]?
            puts x
          @@help_was_printed = true
          return
        end
      end
      DESC.push x
    end # def

    def run_if(x)
      return if IS_HELP
      if x
        yield
        @@action_was_executed = true
        exit 0
      end # if
    end # def

  end # === module
end # === module

