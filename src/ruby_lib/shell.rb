
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

  end # module
end # module
