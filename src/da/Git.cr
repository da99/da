
module DA

  # This is 'hack'-y for now.
  def git_is_clean?
    status = `git status`.strip
    status["Your branch is up to date with 'origin/master'"]? &&
      status["nothing to commit, working tree clean"]?
  end # def git_is_clean

  def git_is_dirty?
    !git_is_clean?
  end

  def git_clone_or_pull(url : String)
    name = File.basename(url, ".git")

    if Dir.exists?(name)
      Dir.cd(name) {
        system("git pull")
        success! $?
      }
    else
      system("git clone --depth 1 #{url}")
      success! $?
    end
  end

  module Git
    extend self

    def development_checkpoint
      DA.success! "git add --all"
      DA.success! "git", ["commit", "-m", "Development checkpoint."]
    end

    def update
      DA.system! "git add --all"
      DA.system! "git status"
      puts_url_origin
    end

    def status
      DA.success! "git status"
      puts_url_origin
    end

    def puts_url_origin
      origin = DA.output!("git remote get-url --all origin").to_s.strip

      if origin.empty?
        DA.exit_with_error!("!!! No origin found.")
      end

      urls = [] of String
      origin.each_line { |line|
        DA.bold!("=== {{#{line}}}")
        urls << line
      }

      # Check if origin fetch/push URLs are the same:
      total = urls.size
      uniqs = urls.sort.uniq.size
      if total != uniqs
        DA.red!("!!! {{origin URL mismatch}} !!")
        return false
      end
      true
    end

    def current_ref
      head = DA_Process.new("git symbolic-ref --quiet HEAD")
      val = if head.success?
              head.output
            else
              rev = DA_Process.new("git rev-parse --short HEAD")
              if rev.success?
                rev.output
              else
                nil
              end
            end
      val && val.to_s.strip
    end

    def repo?
      p = DA_Process.new("git rev-parse --is-inside-work-tree")
      p.success?
    end

    def clean?
      p = DA_Process.new("git status --porcelain")
      p.success? && p.output.to_s.empty?
    end

    def ahead_of_remote?
      p = DA_Process.new("git status --branch --porcelain")
      p.success? && p.output.to_s[/\[\w+ [0-9]+\]/]?
    end

    def zsh_prompt
      prompt = ""
      git_ref = current_ref
      return nil if !git_ref
      ref = git_ref.gsub("refs/heads/master", "")
      is_app = Dir.current["/apps/"]? != nil
      return nil if !repo?
      if clean?
        if ahead_of_remote?
          prompt += "%{%k%F{red}%}↟ "
        else
          prompt += "%{%k%F{green}%} "
        end
      else
        prompt += "%{%k%F{red}%} "
      end
      prompt += ref
    end

    module Files

      PATH = "tmp/out/changed.txt"
      PATH_DO_COMPILE = "tmp/out/do_compile"
      RECORDS = {} of String => Int64
      CHANGED = {} of String => Int64

      def self.load_changes
        return if !RECORDS.empty?

        Dir.mkdir_p(File.dirname(PATH))
        File.touch(PATH)
        File.each_line(PATH) { |line|
          pieces = line.split('|')
          RECORDS[pieces.first] = pieces.last.to_i64
        }
      end

      def self.changed?(file_name)
        # Check if file exists because it might be busy:
        sleep 0.2 if !File.exists?(file_name)
        return true if !File.exists?(file_name)

        current_mtime = File.stat(file_name).mtime.epoch
        result = !RECORDS[file_name]? || RECORDS[file_name] != current_mtime
        RECORDS[file_name] = current_mtime
        result
      end

      def self.update_log
        %w[shard.yml].each { |file|
          next if ! File.exists?(file)
          RECORDS[file] = File.stat(file).mtime.epoch
        }
      end

      def self.ls
        DA_Process.output!("git ls-files --cached --others --exclude-standard")
      end

      def self.changed
        files = [] of String
        ls.each_line { |line|
          if changed?(line)
            files.push(line)
          end
        }
        files
      end

      def self.compile
        return false if !File.exists?(PATH_DO_COMPILE)
        changed.each { |f| yield f }
        yield "compile!"
        File.delete(PATH_DO_COMPILE)
        update_log

        true
      end # === def self.watch

    end # === module Files

  end # === module Git

end # === module DA
