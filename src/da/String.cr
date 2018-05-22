
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

    def orange(raw : String)
      colorize(raw, :yellow)
    end

    def green(raw : String)
      colorize(raw, :green)
    end # === def green

end # === module DA
