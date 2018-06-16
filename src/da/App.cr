
module DA

  struct App

    # =============================================================================
    # Struct:
    # =============================================================================

    def self.remove(app_name : String)
      sv = Runit.new(app_name)
      sv.down! if sv.run?
      sv.wait_pids
      if sv.any_pids_up?
        DA.exit_with_error!("!!! Pids still up for #{app_name}: #{sv.pids_up.join ", "}")
      end
      if sv.linked?
        DA.system!("sudo rm -f #{sv.service_link}")
      end
    end # === def remove

    # =============================================================================
    # Instance:
    # =============================================================================

    getter name   : String
    getter latest : String
    getter dir    : String

    def initialize(@name)
      @dir = if File.directory?("/deploy")
               "/deploy/#{@name}"
             else
               "/apps/#{@name}"
             end
    end # === def initialize

    def latest
      DA::Releases(@dir).pop
    end

    def latest?
      !!@latest
    end # === def latest?

    def latest(dir : String)
      l = latest
      if l
        File.join(l, dir)
      else
        nil
      end
    end # === def latest

    def releases
      DA.releases(@dir)
    end

    def dir(*args)
      File.join(@dir, *args)
    end # === def dir

    {% for x in "Public sv".split %}
      def {{x.id.downcase}}_dir
        File.join(latest, {{x}})
      end # === def public_dir

      def {{x.id.downcase}}_dir?
        File.directory?({{x.id.downcase}}_dir)
      end # === def public_dir
    {% end %}

  end # === struct App
end # === module DA_Deploy
