
module DA
  module Specs
    extend self

    def src
      "specs/__.cr"
    end

    def app_name
      File.basename(Dir.current)
    end

    def bin
      "tmp/out/#{app_name}"
    end

    def compile
      Dir.mkdir_p(File.dirname bin)
      DA::Process::Inherit.new("mkdir -p tmp/out").success!
      DA::Process::Inherit.new("crystal build --warnings all #{src} -o #{bin}").success!
      if File.exists?("specs/__.run.cr")
        DA::Process::Inherit.new("crystal build --warnings all specs/__.run.cr -o tmp/out/__.run").success!
      end
    end

    def run(args = [] of String)
      DA::Process::Inherit.new([bin].concat args).success!
      DA.green! "=== {{DONE}}: BOLD{{#{bin}}} #{args.join ' '} ==="
    end # === def run

  end # === module Specs
end # === module DA_Dev
