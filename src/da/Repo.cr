
module DA

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

  end # === class

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

    def dirty?
      Dir.cd(dir) { Git.dirty? }
    end # def

  end # === class

end # === module DA
