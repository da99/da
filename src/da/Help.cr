
module DA

  macro print_help
    {% begin %}
      _x = {{ system("cat bin/__.cr").lines }}
      DA::Help.print("bin/__.cr", _x, ARGV[1..-1])
    {% end %}
  end # macro print_help

  module Help
    extend self

    DIVIDER = "# === "

    def extract_documentation(file_path : String, substring : String? = nil)
      app_name = File.basename(Dir.current)
      fin = Deque(String).new
      prev_line_was_doc = false
      action_name = File.basename(file_path)
      cmd = "#{app_name}"

      case
      when action_name == "_.sh" || action_name == "_"
        action_name = File.basename(File.dirname(file_path))
        cmd = "#{app_name} #{action_name}"
      end

      if substring && !action_name[substring]?
          return fin
      end

      File.read(file_path).each_line { |l|
        if !l[DIVIDER]? || !(prev_line_was_doc || l[/\\?{\\?{/]?)
          prev_line_was_doc = false
          next
        end

        pieces = l.split(/#{DIVIDER}/)
        next if pieces.size < 2
        pieces.shift



        l = pieces.join(DIVIDER)
        prev_line_was_doc = true
        l = l.gsub(/\\?{\\?{CMD}}/, "{{#{cmd}}}").split.join(' ')
        fin.push(DA.bold l)
      }

      if !fin.empty?
        fin.unshift "\n"
        fin.push "\n"
      end
      fin
    end # === def extract_documentation

    def files
      arr = [] of String

      if File.exists?("bin/__.cr")
        arr.push("bin/__.cr")
      end

      bin_script = "bin/#{File.basename Dir.current}"

      if !Dir.glob("sh/*/").empty?
        arr.concat `find sh/ -type f -path 'sh/*/_'`.strip.split("\n")
      end

      if !Dir.glob("bin/public/*").empty?
        arr.concat `find bin/public/ -type f -path 'bin/public/*/_.sh'`.strip.split("\n")
      end

      if DA.text_file?(bin_script)
        arr.push(bin_script)
      end

      if !Dir.glob("src/*").empty?
        arr.concat `find src -type f -iname '*.cr' -print`.strip.split("\n")
      end

      arr
    end # def files

    def comment?(l : String)
      l =~ /^\ *# / && !(l =~ /={3,}$/)
    end

    def doc_line?(l : String)
      l =~ /^\ *# === / && !(l =~ /={3,}$/)
    end

    def print(file_name, lines, args)
      # doc_string = {{ system("cat bin/__.cr").lines.select { |x| x =~ /^\ *# === / && !(x =~ /={3,}$/) } }}
      delim      = '{'
      delim_end  = '}'
      bin_name   = "#{delim}#{delim}#{DA::Process.bin_name}#{delim_end}#{delim_end}"
      groups = [] of Deque(String)

      while !lines.empty?
        if doc_line?(lines.first)
          group = Deque(String).new
          while !lines.empty? && comment?(lines.first)
            group << lines.shift
          end
          groups << group
        else
          lines.shift
        end
      end # while

      if !args.empty?
        groups = groups.select { |g| g.first[args.first]? }
        if groups.empty?
          DA.red! "!!! No help found for: #{args.first.inspect}"
          exit 1
        end
      end

      puts groups.map { |group|
        group.map { |x|
          DA.bold(
            x
            .gsub("#{delim}#{delim}CMD#{delim_end}#{delim_end}", bin_name)
            .gsub(/^\ *# === /, "  ")
            .gsub(/^\ *# /, "    ")
          )
        }.join('\n')
      }.join('\n')
    end

  end # === module Documentation

end # === module DA_Dev
