
require "colorize"
require "./Dev"

module DA

  module Color_String
    PATTERN = /\{\{([^\}]+)\}\}/
    BOLD_PATTERN = /BOLD{{([^\}]+)}}/

    def bold(raw : String)
      raw.gsub(PATTERN) { |raw, match|
        match.captures.first.not_nil!.colorize.bold
      }.gsub(BOLD_PATTERN) { |raw, match|
        match.captures.first.not_nil!.colorize.bold
      }
    end

    def colorize(color : Symbol, raw : String)
      color = :yellow if color == :orange
      raw.
        gsub(BOLD_PATTERN) { |raw, match|
        match.captures.first.not_nil!.colorize.mode(:bold)
      }.
      gsub(PATTERN) { |raw, match|
        x = match.captures.first.not_nil!.colorize
        case color
        when :bold
          x.bold
        else
          x.fore(color).bold
        end
      }
    end

    def debug(s : String)
      return false unless debug?
      case
      when STDERR.tty?
        STDERR.puts orange(s)
      when STDOUT.tty?
        STDOUT.puts orange(s)
      end
    end # def

    def orange!(e : ::Exception)
      msg = e.message
      DA.orange! "BOLD{{#{e.class}}}: {{#{msg.inspect}}}"
      if e.backtrace?
        e.backtrace.each { |l|
          DA.orange! l.to_s
        }
      end
      e
    end # === def

    def red!(raw)
      stderr!(:red, raw)
    end # def

    def orange!(raw)
      stderr!(:yellow, raw)
    end # === def orange!

    def green!(raw)
      stderr! :green, raw
    end # === def green

    def stderr!(color, raw)
      if STDERR.tty?
        return(STDERR.puts colorize(color, raw))
      end # if

      STDERR.puts(raw)
    end # def

    def sections(content : String, pattern)
      pieces = content.split(pattern).map(&.strip).reject(&.empty?)
      case
      when pieces.size == 0
        return content
      when pieces.size == 1
        return content
      when !pieces.size.even?
        return content
      else
        fin = {} of String => String
        pieces.each_with_index { |v, i|
          case
          when i.even? || i == 0
            fin[v] = pieces[i+1]
          end
        }
        fin
      end # case
    end # === def
  end # === module

  extend Color_String

end # === module DA
