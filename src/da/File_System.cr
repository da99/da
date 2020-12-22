
require "file_utils"

module DA

  module File_System
    extend self

    def dirs(raw : Array(String))
      DIRS.new(raw)
    end # def

    def usb_drives
      `lsblk -l`.strip.split('\n').select { |line|
        # NAME      MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        #  0           1     2     3   4  5    6
        pieces = line.split
        name, type = pieces[0], pieces[5]
        type == "disk" && name[/^sd/]?
      }
    end

    def text_file?(s : String)
      File.exists?(s) && `file --mime #{s}`["text/plain"]?
    end

    def public_dir?(raw : String)
      public_dir = temp = File.expand_path(raw)
      return false if !File.directory?(public_dir)
      while temp.size > 1
        perms = File.info(temp).permissions
        if !(perms.other_read? && perms.other_execute?)
          return false
        end
        temp = File.dirname(temp)
      end
      true
    end # === def public_dir_permissions

    def symlink!(original, target)
      if !File.exists?(original)
        raise Exception.new "Symbolic link origin does not exist: #{original}"
      end

      if File.symlink?(target) && !File.exists?(target)
        DA.orange!("Link exists, but is broken: #{target}")
      end

      if File.exists?(target) && !File.symlink?(target)
        raise Exception.new("Symbolic link target already exists: #{target}")
      end

      if File.symlink?(target) && File.exists?(target) && File.real_path(original) == File.real_path(target)
        DA.orange! "=== Already linked: #{original} -> #{target}"
        return true
      end

      cmd = "ln -s -f --no-dereference #{original} #{target}"
      return true if DA::Process::Inherit.new(cmd).success?

      DA::Process::Inherit.new("sudo #{cmd}").success!
      true
    end # === def symlink!

    class DIR
      getter raw : String

      def initialize(@raw = Dir.current)
      end # def

      def exist!
        raise Exception.new("Directory does not exist: #{@raw.inspect}") unless Dir.exists?(@raw)
        self
      end # def

      def dirs(level : Int32)
        new_raw = Process
          .new(["find", raw].concat("-mindepth #{level} -maxdepth #{level} -type d".split))
          .success!
          .output.to_s.strip.split('\n')
        DIRS.new(new_raw)
      end # def

      def files
        FILES.new(
          Process
          .new(["find", raw].concat("-mindepth #{level} -maxdepth #{level} -type f".split))
          .success!
          .output.to_s.strip.split('\n')
        )
      end # def

      def exists
        if Dir.exists?(@raw)
          return(yield self)
        end
        self
      end # def

    end # === class

    class DIRS
      getter raw : Array(String)

      def initialize(@raw = Array(String).new)
      end # def

      def prefix(raw)
        @raw.map! { |x| File.join raw, x }
        self
      end # def

      def exists
        @raw.select! { |x| Dir.exists?(x) }
        self
      end # def

      def files
        FILES.new(self)
      end # def

      def basename
        @raw.map! { |x| File.basename x }
        self
      end # def

      def copy(src_base : String | Path, dest_base : String | Path)
        @raw.each { |dir|
          FileUtils.cp_r(
            File.join(src_base, dir),
            File.join(dest_base, dir)
          )
        }
      end # def

    end # === class

    module FILE
      def self.copy(src, dest)
        src_content    = File.read(src)
        if File.exists?(dest) && File.read(dest) == src_content
          if DA.debug?
            DA.orange! "=== {{File already copied}}: BOLD{{#{src}}} -> #{dest}"
          end
          return false
        end # if
        Dir.mkdir_p(File.dirname(dest))
        File.copy(src, dest)
      end # def
    end # === module

    class FILES

      def self.find(raw_dirs : Array(String), pattern)
        dirs = raw_dirs.select { |x| Dir.exists?(x) }
        return([] of String) if dirs.empty?
        args = ["find"].concat( dirs ).concat("-readable -type f".split)
        Process::Inherit.new(args).success!.output.to_s.strip.split('\n').select { |x| x[pattern]? }
      end # def

      include Enumerable(String)

      getter raw : Array(String)

      def initialize(dirs : DIRS)
        args = ["find"].concat( dirs.raw ).concat("-readable -type f".split)
        @raw = Process.new(args).success!.output.to_s.strip.split('\n')
      end # def

      def initialize(dir : String = Dir.current)
        @raw = if Dir.exists?(dir)
                   f = Process.new(%{find #{dir} -type f -print})
                   f.success!
                   f.output.to_s.strip.split('\n')
                 else
                   [] of String
                 end
      end # def

      def select(r : Regex)
        @raw.select! { |f| f[r]? }
        self
      end # def

      def relative_to(str : String)
        @raw.map! { |f| Path.posix(f).relative_to(str).to_s }
        self
      end # def

      def copy(src : String, dest : String)
        @raw.each { |file|
          FILE.copy(File.join(src, file), File.join(dest, file))
        }
      end # def

      def copy(dest : String)
        @raw.each { |file| FILE.copy(file, File.join(dest, file)) }
      end # def

      def each
        files.each { |x| yield x }
      end # def

    end # === struct
  end # module
end # === module DA
