
module DA

  module Git
    extend self

    def clone_or_pull(url : String)
      name = File.basename(url, ".git")

      if Dir.exists?(name)
        Dir.cd(name) {
          system("git pull --no-rebase")
          success! $?
        }
      else
        system("git clone --depth 1 #{url}")
        success! $?
      end
    end

    def update
      DA::Process::Inherit.new("git add --all").success!
      DA::Process::Inherit.new("git status").success!
      puts_url_origin
    end

    def status
      DA::Process::Inherit.new("git status").success!
      puts_url_origin
    end

    def puts_url_origin
      origin = DA::Process.new("git remote get-url --all origin").out_err.strip

      if origin.empty?
        DA.red!("!!! No origin found.")
        exit 1
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
      head = DA::Process.new("git symbolic-ref --quiet HEAD")
      val = if head.success?
              head.output
            else
              rev = DA::Process.new("git rev-parse --short HEAD")
              if rev.success?
                rev.output
              else
                nil
              end
            end
      val && val.to_s.strip
    end

    def repo?
      DA::Process.new("git rev-parse --is-inside-work-tree").success?
    end

    def ahead_of_remote?
      p = DA::Process.new("git status --branch --porcelain")
      p.success? && p.output.to_s[/\[\w+ [0-9]+\]/]?
    end

    def zsh_prompt
      prompt = ""
      git_ref = current_ref
      return nil if !git_ref
      ref = git_ref.gsub("refs/heads/master", "")
      is_app = Dir.current["/apps/"]? != nil
      return nil if !repo?
      if Repo.new(Dir.current).clean?
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

    class Repos

      getter dir : String

      def initialize(raw_dir : String)
        @dir = raw_dir.strip
        raise "Invalid directory: #{raw_dir.inspect}" unless File.directory?(@dir)
      end # def

      def names
        `find -L "#{dir}" -mindepth 1 -maxdepth 1 -type d`.strip.split('\n').map { |x|
          basename = File.basename(x)
          next if basename.empty? ||  basename.index('.') == 0 || basename == "lost+found"
          basename
        }.compact.sort
      end # def

      def repos
        names.map { |r| Repo.new(File.join(dir, r)) }
      end # def

    end # === class Repos

    class Repo
      module Class_Methods

        def next_dirty(repo_dir, repo_dirs)
          begin
            Repo.new(repo_dir)
          rescue e : Exception
          end
          repos_dir = parent_dir
          name      = name! rescue :none
          all_repos = all!

          DA.each_after(all_repos, name) { |x|
            Dir.cd(File.join repos_dir, x) {
              return Dir.current if Git.dirty?
            }
          }

          # If no dirty repo found, search before repo.
          DA.each_until(all_repos, name) { |x|
            Dir.cd(File.join repos_dir, x) {
              return Dir.current if Git.dirty?
            }
          }

          return nil
        end # def next_repo

      end # === module

      extend Class_Methods

      getter dir : String

      def initialize(raw_dir)
        @dir = Dir.cd(raw_dir) { `git rev-parse --show-toplevel 2>/dev/null`.strip }
        raise("Git repo not found for: #{raw_dir.inspect}") if raw_dir.empty?
      end # def

      def name
        File.basename dir
      end # def

      def parent_dir
        File.dirname(dir)
      end # def

      def repos_dir
        Repos.new(parent_dir)
      end # def

      def clean?
        Dir.cd(dir) {
          return false if !File.directory?(".git")
          return false if commit_pending?
          has_origin = !`git remote -v`.strip.empty?
          if has_origin
            return !!(`git status`.strip[/Your branch is up to date with 'origin\/(main|master)'/]?)
          end
          true
        }
      end # def git_is_clean

      def dirty?
        Dir.cd(dir) { !clean? }
      end # def

      def previous
        DA.each_after(repos_dir.repos.reverse, ->(x : Repo) { x.name == name}) { |r|
          return r if yield(r)
        }
      end # def

      def next
        DA.each_after(repos_dir.repos, ->(x : Repo) { x.name == name}) { |r|
          return r if yield(r)
        }
      end # def

      def development_checkpoint
        Dir.cd(dir) {
          if DA::Process::Inherit.new("git diff --cached --exit-code").success?
            DA.red! "Nothing has been staged."
            exit 1
          end
          DA::Process::Inherit.new("git add --all").success!
          DA::Process::Inherit.new("git commit -m Development checkpoint.").success!
        }
      end

      def commit_pending?
        Dir.cd(dir) {
          proc = DA::Process.new("git status --porcelain")
          !proc.success? || !proc.output.empty? || !proc.error.empty?
        }
      end # def

      def commit(args : Array(String))
        Dir.cd(dir) {
          if !File.directory?(".git")
            DA.red!("Not a git directory: #{Dir.current}")
            exit 1
          end

          if !commit_pending?
            DA.red!("Nothing to commit: #{Dir.current}")
            exit 1
          end

          DA::Process::Inherit.new(["git", "commit"].concat(args)).success!
        }
      end # def

    end # === class Repo
  end # === module Git
end # === module DA
