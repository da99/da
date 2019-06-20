
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
      DA.system!("mkdir -p tmp/out")
      DA.system!("crystal build --warnings all #{src} -o #{bin}")
    end

    def run(args = [] of String)
      DA.system!(bin, args)
      DA.green! "=== {{DONE}}: BOLD{{#{bin}}} #{args.join ' '} ==="
    end # === def run

  end # === module Specs
end # === module DA_Dev
