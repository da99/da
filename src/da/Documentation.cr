
module DA_Dev
  module Documentation
    extend self

    DIVIDER = "# === "

    def compile(files : Array(String))
      app_name = File.basename(Dir.current)
      fin = Deque(String).new
      files.each { |f|
        prev_line_was_doc = false
        File.read(f).each_line { |l|
          if !l[DIVIDER]? || !(prev_line_was_doc || l["{{"]?)
            prev_line_was_doc = false
            next
          end

          pieces = l.split(/#{DIVIDER}/)
          next if pieces.size < 2

          prev_line_was_doc = true
          pieces.shift
          l = pieces.join(DIVIDER)

          l = l.gsub("{{CMD}}", "{{#{app_name}}}").split.join(' ')
          fin.push(DA_Dev::Colorize.bold l)
        }
      }
      if !fin.empty?
        fin.unshift "\n"
        fin.push "\n"
      end
      fin
    end # === def print_help

    def print_help(*args)
      compile(*args).each { |l|
        puts l
      }
    end

  end # === module Documentation
end # === module DA_Dev
