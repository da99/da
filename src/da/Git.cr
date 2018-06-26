
module DA

  module Git
    extend self

    def commit(args : Array(String))
      if clean?
        raise DA::Exit.new(1, "Nothing to commit. Directory is clean: #{Dir.current}")
      end

      if !File.directory?(".git")
        raise DA::Exit.new(1, "Not a git directory: #{Dir.current}")
      end

      if File.exists?("bin/__.cr")
        DA::Crystal.bin_compile
      end
      DA.system! "git add bin/#{File.basename Dir.current}"
      DA.system! "git", ["commit"].concat(args)
    end

    # This is a hacky implementation, but so far it works for me.
    def clean?
      status = `git status`.strip
      is_committed = status["nothing to commit, working tree clean"]?
      return false if !is_committed
      has_origin = !`git remote -v`.strip.empty?
      if has_origin
        return !!status["Your branch is up to date with 'origin/master'"]?
      end
      true
    end # def git_is_clean

    def dirty?
      !clean?
    end

    def clone_or_pull(url : String)
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

    def development_checkpoint
      DA.success! "git add --all"
      DA.success! "git commit -m Development checkpoint."
    end

    def update
      DA.system! "git add --all"
      DA.system! "git status"
      puts_url_origin
    end

    def status
      DA.system! "git status"
      puts_url_origin
    end

    def puts_url_origin
      origin = DA.output!("git remote get-url --all origin").to_s.strip

      if origin.empty?
        DA.exit!("!!! No origin found.")
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
      head = DA.process_new("git symbolic-ref --quiet HEAD")
      val = if head.success?
              head.output
            else
              rev = DA.process_new("git rev-parse --short HEAD")
              if rev.success?
                rev.output
              else
                nil
              end
            end
      val && val.to_s.strip
    end

    def repo?
      DA.success?("git rev-parse --is-inside-work-tree")
    end

    def ahead_of_remote?
      p = DA.process_new("git status --branch --porcelain")
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
    end # def

  end # === module Git
end # === module DA
