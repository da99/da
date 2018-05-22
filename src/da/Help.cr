
module DA
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
        if !l[DIVIDER]? || !(prev_line_was_doc || l["{{"]?)
          prev_line_was_doc = false
          next
        end

        pieces = l.split(/#{DIVIDER}/)
        next if pieces.size < 2
        pieces.shift



        l = pieces.join(DIVIDER)
        prev_line_was_doc = true
        l = l.gsub("{{CMD}}", "{{#{cmd}}}").split.join(' ')
        fin.push(DA.bold l)
      }

      if !fin.empty?
        fin.unshift "\n"
        fin.push "\n"
      end
      fin
    end # === def print_help

    def files
      arr = [] of String

      if File.exists?("bin/__.cr")
        arr.push("bin/__.cr")
      end

      bin_script = "bin/#{File.basename Dir.current}"

      if Dir.exists?("sh")
        arr.concat `find sh/ -type f -path 'sh/*/_'`.strip.split("\n")
      end

      if Dir.exists?("bin/public")
        arr.concat `find bin/public/ -type f -path 'bin/public/*/_.sh'`.strip.split("\n")
      end

      if DA.text_file?(bin_script)
        arr.push(bin_script)
      end

      if Dir.exists?("src")
        arr.concat `find src -type f -iname '*.cr' -print`.strip.split("\n")
      end

      arr
    end # def files

    def print(*substring)
      files.each { |f|
        extract_documentation(f, *substring).map { |l| puts "  #{l}" }
      }
    end

  end # === module Documentation
end # === module DA_Dev
