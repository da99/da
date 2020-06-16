
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

  def on_debug(s : String)
    return false unless debug?
    case
    when STDERR.tty?
      STDERR.puts orange(s)
    when STDOUT.tty?
      STDOUT.puts orange(s)
    else
      STDERR.puts s
    end
  end # def

  def orange!(e : ::Exception)
    msg = e.message
    if msg
      DA.orange! "#{e.class}: #{msg}"
    else
      DA.orange! "#{e.class}: #{msg.inspect}"
    end
    if e.backtrace?
      e.backtrace.each { |l|
        DA.orange! l.to_s
      }
    end
    e
  end # === def

  def orange!(*args : String)
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

end # === module DA
