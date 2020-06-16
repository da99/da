
module DA

  module Repo
    extend self

    def parent_dir
      File.dirname(dir!) rescue Dir.current
    end # def

    # Returns name of the current or top-most parent that is a git repo.
    def dir!
      dir = `git rev-parse --show-toplevel 2>/dev/null`.strip
      raise("Git repo not found.") if dir.empty? || !File.directory?(dir)
      dir
    end # def

    def name!
      File.basename(dir!)
    end # def

    def all!
      fin = Array(String).new
      Dir.cd(parent_dir) {
        `find "#{parent_dir}" -mindepth 1 -maxdepth 1 -type d`.strip.split('\n').each { |x|
          basename = File.basename(x)
          next if basename[".Trash"]? || basename == "lost+found"
          fin.push(basename)
        }
      }
      raise "No repos found." if fin.empty?
      fin.sort
    end # def

    def next_dirty
      repos_dir = parent_dir

      DA.each_after(all!, name!) { |x|
        Dir.cd(File.join repos_dir, x) {
          return x if Git.dirty?
        }
      }
      return nil
    end # def next_repo

    def next
      name = name! rescue nil

      if !name
        all!.first
      else
        found_current = false
        all!.each { |x|
          return x if found_current
          found_current = true if x == name
        }
      end

      nil
    end # === def next_repo

  end # === module

end # === module DA
