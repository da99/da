
require "colorize"

module DA
    PATTERN = /\{\{([^\}]+)\}\}/
    BOLD_PATTERN = /BOLD{{([^\}]+)}}/

    def highlight_exception(e : Exception) : String
      msg = e.message || "[#{e.class}]"
      msg = msg.sub(/[^\:]+\: /) { |x| "{{#{x.sub(": ", "")}}}: " }
      "!!! #{msg}"
    end

    def bold(raw : String)
      raw.gsub(PATTERN) { |raw, match|
        match.captures.first.not_nil!.colorize.mode(:bold)
      }.gsub(BOLD_PATTERN) { |raw, match|
        match.captures.first.not_nil!.colorize.mode(:bold)
      }
    end

    def bold!(*args)
      if STDOUT.tty?
        STDOUT.puts bold(*args)
      else
        STDOUT.puts *args
      end
    end # === def bold!

    def colorize(raw : String, color : Symbol)
      raw
        .gsub(BOLD_PATTERN) { |raw, match|
        match.captures.first.not_nil!.colorize.mode(:bold)
      }
        .gsub(PATTERN) { |raw, match|
        match.captures.first.not_nil!.colorize.fore(color).mode(:bold)
      }
    end

    def red(raw : String)
      colorize(raw, :red)
    end

    def red!(*args)
      if STDERR.tty?
        STDERR.puts red(*args)
      else
        STDERR.puts(*args)
      end
    end

    def orange(raw : String)
      colorize(raw, :yellow)
    end

    def orange!(*args)
      if STDERR.tty?
        STDERR.puts orange(*args)
      else
        STDERR.puts(*args)
      end
    end # === def orange!

    def green(raw : String)
      colorize(raw, :green)
    end # === def green

    def green!(*args)
      if STDOUT.tty?
        STDOUT.puts green(*args)
      else
        STDOUT.puts(*args)
      end
    end # === def green

end # === module DA
