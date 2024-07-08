
module Shell
  module String

    extend self

    def bold(content)
      return "\e[1m#{content}\e[0m"
    end

    def italics(content)
      return "\e[3m#{content}\e[0m"
    end

    def red(content)
      return "\e[31m#{content}\e[0m"
    end

    def green(content)
      return "\e[32m#{content}\e[0m"
    end

    def yellow(content)
      return "\e[33m#{content}\e[0m"
    end

    def blue(content)
      return "\e[34m#{content}\e[0m"
    end

    def white(content)
      return "\e[37m#{content}\e[0m"
    end

    def remove_trailing_asterisk(raw)
      raw.strip.sub(/\ +\*\ */, '')
    end

    def format_command_comment(raw)
      content = raw.strip

      return content if content.empty?
      return Shell::String.yellow(raw.strip) if content[/^-\ +/]

      pieces = content.split('-')
      prefix = pieces.shift.strip
      return prefix if pieces.empty?

      "#{prefix} #{Shell::String.yellow('-' + pieces.join('-'))}"
    end

  end # module
end # module
