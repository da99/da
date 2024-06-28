
module DA
  struct Public_Dir

    getter name        : String
    getter app_dir     : String
    getter public_link : String
    getter app         : App

    def initialize(@name)
      @app         = App.new(@name)
      @app_dir     = @app.dir
      @public_link = File.join(@app_dir, "Public")
    end # === def initialize

    def latest?
      !!latest
    end

    def latest
      releases.last?
    end

    def releases
      Dir.glob( File.join("#{app_dir}/*/Public") ).sort.map { |x|
        next if !File.directory?(x)
        x
      }.compact
    end

    def linked?
      origin = latest
      return false if !origin
      `realpath #{public_link}` == `realpath #{origin}`
    end # === def linked?

    def link!
      if linked?
        DA.orange!("=== Already linked: #{public_link} -> {{#{latest}}}")
        return false
      end

      origin = latest
      DA.system!("sudo rm -f #{public_link}")
      raise Exception.new("No latest release found for: #{name}") if !origin
      DA.system!("sudo ln -s #{origin} #{public_link}")
    end # === def install!

  end # === struct Public_Dir
end # === module MINIUNI
