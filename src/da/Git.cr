
require "./Process"
require "./NPM"

module DA

  def self.backup
    config = "config/dev/repos"
    repos = ["origin"]
    shell_script = "sh/backup.sh"

    if File.exists?(shell_script)
      DA::Process::Inherit.new(shell_script).success!
    end

    if File.exists?(config)
      repos = File.read(config).split.concat(repos)
    end

    configured = nil
    repos.each { |repo|
      DA.orange! "=== {{#{repo}}} ==="

      if DA::Process.new("git remote show #{repo}").out_err[/configured.+git push/i]?
        configured = true
      end

      if repo == "origin" && !configured
        DA::Process::Inherit.new("git push -u #{repo} main").success!
      else
        DA::Process::Inherit.new("git push #{repo}").success!
      end
    }
  end # def

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

    def repo?(x : String)
      Dir.cd(x) {
        DA::Process.new("git rev-parse --is-inside-work-tree").success?
      }
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
        raise("Git repo not found for: #{raw_dir.inspect}") if @dir.empty?
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

      def tags
        `git tag`.strip.split('\n')
      end # def

      def latest_tag
        tags.reverse.find { |x| x[/^v\d+\.\d+\.\d+$/] }.not_nil!
      end # def

      def next(dirs : Array(String)?)
        repos = (dirs || [] of String).unshift(parent_dir).
          uniq.
          map { |d| Repos.new(d) }.
          map { |rd| rd.repos }.
          flatten
        DA.each_after(repos, ->(x : Repo) { x.dir == dir }) { |r|
          return r if yield(r)
        }
      end # def

      def staged?
        Dir.cd(dir) {
          !DA::Process.new("git diff --cached --exit-code").success?
        }
      end # def

      def development_checkpoint
        Dir.cd(dir) {
          if !staged?
            DA.red! "Nothing has been staged."
            exit 1
          end
          DA::Process::Inherit.new(["git", "status"]).success!
          DA::Process::Inherit.new(["git", "commit", "-m", "Development checkpoint."]).success!
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

      def status
        DA::Process.new("git status").success!.out_err
      end # def status

      def errors
        errs = [] of String
        Dir.cd(dir) {
          if !Dir.exists?(".git")
            errs << "Not a git repository."
          end
        }
        urls = remote_origin_urls
        # Check if origin fetch/push URLs are the same:
        total = urls.size
        uniqs = urls.sort.uniq.size
        case
        when urls.empty?
          errs << "No remote {{origin}} specified."
        when total != uniqs
          errs << "!!! {{origin URL mismatch}} !!:\n #{urls.join '\n'}"
        end # case

        errs
      end # def

      def remote_origin_urls
        urls = [] of String
        origin = Dir.cd(dir) { DA::Process.new("git remote get-url --all origin").output.to_s.strip }
        origin.each_line { |line| urls << line }
        urls
      end # def

      def bump(target)
        case target
        when "major"
        when "minor"
        when "patch"
        else
          raise Exception.new("Invalid target name: #{target.inspect}")
        end # case

        if commit_pending?
          DA.red! "Repo has {{pending commits}}."
          exit 1
        end

        Dir.cd(dir) {
          old_version = begin
                          case
                          when crystal?
                            `shards version`.strip
                          else
                            latest_tag.split("v").last || ""
                          end # case
                        end

          if old_version.empty?
            raise Exception.new("Version not found.")
          end

          pieces = old_version.split('.').map { |x| x.to_i32 }
          new_version = begin
                          case target
                          when "major"
                            pieces[0] = pieces.first + 1
                          when "minor"
                            pieces[1] = pieces[1] + 1
                          else
                            pieces[2] = pieces[2] + 1
                          end
                          pieces.join '.'
                        end # begin
          if crystal?
            File.write(
              "shard.yml",
              File.read("shard.yml").sub("version: #{old_version}", "version: #{new_version}")
            )
            Process::Inherit.new("git add shard.yml".split).success!
            Process::Inherit.new(["git", "commit", "-am", "Bump: v#{new_version}"]).success!
          else
            DA.red! "Unknown repo tag to bump."
            exit 1
          end

          Process::Inherit.new(["git", "tag", "v#{new_version}"]).success!
          Process::Inherit.new(["git", "push", "--tag"]).success!

        }
      end # def

      def crystal?
        Dir.cd(dir) { File.exists?("shard.yml") }
      end # def

      def nodejs?
        Dir.cd(dir) { File.exists?("package.json") }
      end # def

      def typescript?
        Dir.cd(dir) { File.exists?("tsconfig.json") }
      end # def

      def wrangler?
        Dir.cd(dir) { File.exists?("wrangler.toml") }
      end # def

      def update_tree
        Dir.cd(dir) {
          DA::Process::Inherit.new("git add --all").success!
          DA::Process::Inherit.new("git status").success!
        }
      end # def

      def update_packages
        Dir.cd(dir) {
          if crystal?
            DA::Process::Inherit.new("shards install".split).success!
            DA::Process::Inherit.new("shards update".split).success!
            DA::Process::Inherit.new("shards prune".split).success!
          end
          if nodejs?
            DA::Process::Inherit.new("npm install".split).success!
            DA::Process::Inherit.new("npm update".split).success!
            DA::Process::Inherit.new("npm prune".split).success!
            npm_dir = DA::NPM::Package_JSON.from_dir(Dir.current)
            npm_dir.git_modules.each { |x| x.update! if x.update? }
          end
        }
      end # def

    end # === class Repo
  end # === module Git
end # === module DA
