
module DA

  # =============================================================================
  module Release

    extend self

    def is?(dir)
      File.basename(dir)[/^\d{10}-[\da-zA-Z]{7}$/]?
    end

    def list(dir : String)
      Dir.glob("#{dir}/*/").sort.map { |dir|
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
        output = DA.output!("git show -s --format=%ct-%h")
      }
      output.not_nil!
    end

    def latest(dir : String)
      list(dir).last?
    end # === def latest(dir : String)

    def latest!(dir : String)
      r = DA::Release.list(dir).last?
      if !r
        DA.exit_with_error!("!!! No latest release found for #{dir}")
      end
      r
    end # === def self.latest_release

  end # === module Release

end # === module DA
