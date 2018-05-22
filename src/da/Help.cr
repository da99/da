
module DA
  module Help
    extend self

    DIVIDER = "# === "

    def extract_documentation(file_path : String)
      app_name = File.basename(Dir.current)
      fin = Deque(String).new
      prev_line_was_doc = false
      File.read(file_path).each_line { |l|
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
        fin.push(DA.bold l)
      }
      if !fin.empty?
        fin.unshift "\n"
        fin.push "\n"
      end
      fin
    end # === def print_help

    def print
      files = [] of String

      if File.exists?("bin/__.cr")
        files.push("bin/__.cr")
      end

      bin_script = "bin/#{File.basename Dir.current}"

      if DA.text_file?(bin_script)
        files.push(bin_script)
      end

      if Dir.exists?("src")
        files.concat `find src -type f -iname '*.cr' -print`.strip.split("\n")
      end

      files.each { |f|
        extract_documentation(f).map { |l| puts "  #{l}" }
      }
    end

  end # === module Documentation
end # === module DA_Dev
