
module DA

  # =============================================================================
  module Release

    extend self

    def is?(dir)
      File.basename(dir)[/^\d{10}-[\da-zA-Z]{7}$/]?
    end

    def list(app : App)
      Dir.glob("#{app.dir}/*").sort.map { |dir|
        next unless is?(dir)
        dir
      }.compact
    end

    def generate_id
      generate_id Dir.current
    end

    def generate_id(dir) : String
      output = nil
      Dir.cd(dir) {
        output = DA::Process.new("git show -s --format=%ct-%h").success!.out_err
      }
      output.not_nil!
    end

    def latest(app : App)
      list(app).last?
    end # === def latest(dir : String)

    def latest!(app : App)
      r = DA::Release.list(app).last?
      if !r
        DA::Process.new("!!! No latest release found for #{app.dir}")
        exit 1
      end
      r
    end # === def self.latest_release

  end # === module Release

end # === module DA
