
require "file_utils"

module DA

  module File_System
    extend self

    def free_space(x : String)
      val = `df #{x} | tail -n 1 | tr -s ' ' | cut -d' ' -f4`.strip
      if val.empty?
        raise "free_space could not be determined for #{x.inspect}"
      end
      val.to_i
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

      def copy_unless_exists(desired, default)
        Dir.cd(raw) {
          return self if File.exists?(desired)
          FileUtils.cp(default, desired)
        }
        self
      end # def

      def link_unless_exists(desired, default)
        Dir.cd(raw) {
          return self if Dir.exists?(desired)
          FileUtils.ln_s(default, desired)
        }
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
        FILES.new( self )
      end # def

      def exists
        if Dir.exists?(@raw)
          return(yield self)
        end
        self
      end # def

      def to_s(io)
        @raw.to_s(io)
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

      def each
        @raw.each { |x| yield x }
        self
      end # def

      def select(pattern)
        @raw.select! { |x| x[pattern]? }
        self
      end # def

      def select
        @raw.select! { |x| yield x }
        self
      end # def

      def map
        @raw.map! { |x| yield x }
        self
      end # def

    end # === class

    class FILE
      getter raw : String

      def initialize(@raw)
      end # def

      def new
        self.class.new(raw)
      end # def

      def new
        x = self.class.new(raw)
        yield x
        x
      end # def

      def touch
        File.touch(raw)
        self
      end # def

      def default_content(raw_content : String)
        if !exists?
          File.write(raw, raw_content)
        end
        self
      end # def

      def move(f : FILE)
        move(f.raw)
      end # def

      def move(new_file : String)
        FileUtils.mv(raw, new_file) unless File.expand_path(raw) == File.expand_path(new_file)
        self
      end # def

      def exists?
        File.exists?(raw)
      end # def

      def remove
        FileUtils.rm(raw)
        self
      end

      def rename_ext(old, new : String)
        base = raw.rchop(old)
        if base == raw
          raise Exception.new("File with extension #{old.inspect} not found: #{raw.inspect}")
        end
        self.class.new "#{base}#{new}"
      end # def

      def rename_ext(old, new : Enumerable(String))
        new.map { |new_e| rename_ext(old, new_e) }
      end # def

      def append_ext(new_e : String)
        self.class.new "#{raw}#{new_e}"
      end # def

      def append_ext(new : Enumerable(String))
        new.map { |new_e| append_ext(new_e) }
      end # def

      def copy(dest_file : FILE)
        src = raw
        dest = dest_file.raw
        src_content = File.read(src)
        if File.exists?(dest)
          if File.read(dest) == src_content
            DA.orange!(%[=== {{File already copied}}: #{src} -> #{dest}]) if DA.debug?
            return false
          else
            DA.orange!(%[=== {{File already exists}}: #{src} -> #{dest}]) if DA.debug?
            exit 1
          end # if
          return false
        end # if
        Dir.mkdir_p(File.dirname(dest))
        FileUtil.cp(src, dest)
        self
      end # def

      def basename
        File.basename raw
      end # def

      def to_s(io)
        @raw.to_s(io)
      end # def

    end # === module

    class FILES

      def self.find(raw_dirs : Array(String), pattern)
        dirs = raw_dirs.select { |x| Dir.exists?(x) }
        return([] of String) if dirs.empty?
        args = ["find"].concat( dirs ).concat("-readable -type f".split)
        Process::Inherit.new(args).success!.output.to_s.strip.split('\n').select { |x| x[pattern]? }
      end # def

      getter raw : Array(String)

      def initialize(dir : DIR)
        args = ["find", dir.raw].concat("-readable -type f".split)
        @raw = Process.new(args).success!.output.to_s.strip.split('\n')
      end # def

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

      def initialize(files : FILES)
        @raw = files.raw.dup
      end # def

      def new
        self.class.new(self)
      end # def

      def reject(r : Regex)
        @raw.reject! { |f| f[r]? }
        self
      end # def

      def relative_to(str : String)
        @raw.map! { |f| Path.posix(f).relative_to(str).to_s }
        self
      end # def

      def each
        @raw.each { |x| yield x }
        self
      end # def

      def each_file
        @raw.each { |x| yield FILE.new(x) }
        self
      end # def

      def any?(pattern)
        @raw.any? { |x| x[pattern]? }
      end # def

      def select(r)
        @raw.select! { |f| f[r]? }
        self
      end # def

      def select_basename(r)
        @raw.select! { |f| File.basename(f)[r]? }
        self
      end # def

      def select_ext(ext)
        r = /#{Regex.escape ext}$/
        @raw.select! { |f| f[r]? }
        self
      end # def

      def rename_ext(old_e, new_e)
        r = /#{Regex.escape(old_e)}$/
        @raw.map! { |f|
          f.sub(r, new_e)
        }
        self
      end # def

      def move_ext(old_e : String, new_e)
        move_ext(/#{Regex.escape old_e}$/, new_e)
      end # def

      def move_ext(old_e : Regex, new_e)
        each_file { |f|
          new_f = f.new.ext(old_e, new_e)
          f.mv(new_f) unless new_f.raw == f.raw
        }
        self
      end # def

      def rm
        @raw.each { |x| FileUtils.rm x }
        self
      end # def

      def basename
        @raw.map! { |x| File.basename x }
        self
      end # def

    end # === struct
  end # module
end # === module DA
