
module DA

  def is_release?(dir)
    File.basename(dir)[/^\d{10}-[\da-zA-Z]{7}$/]?
  end

  def releases(dir : String)
    Dir.glob("#{dir}/*/").sort.map { |dir|
      next unless is_release?(dir)
      dir
    }.compact
  end

  # =============================================================================
  module Release
    extend self

    def generate_id
      `git show -s --format=%ct-%h`.strip
    end

    def latest(dir : String)
      releases.last?
    end # === def latest(dir : String)

    def latest!(dir : String)
      d = DA.releases(dir).last?
      if !d || !File.directory?(d)
        DA.exit_with_error!("!!! No latest release found for #{dir}")
      end
      d
    end # === def self.latest_release

  end # === module Release

end # === module DA
