
module DA

  struct App

    # =============================================================================
    # Struct:
    # =============================================================================

    # =============================================================================
    # Instance:
    # =============================================================================

    getter name   : String
    getter dir    : String

    def initialize(@name)
      @dir = if File.directory?("/deploy") || !DA.is_development?
               "/deploy/#{@name}"
             else
               "/apps/#{@name}"
             end
    end # === def initialize

    def latest
      DA.releases(@dir).pop
    end

    def latest?
      !!latest
    end # === def latest?

    def latest(dir : String)
      l = latest
      if l
        File.join(l, dir)
      else
        nil
      end
    end # === def latest

    def remove!
      sv = Runit.new(name)
      sv.down! if sv.run?
      sv.wait_pids
      if sv.any_pids_up?
        DA.exit_with_error!("!!! Pids still up for #{name}: #{sv.pids_up.join ", "}")
      end
      if sv.linked?
        DA.system!("sudo rm -f #{sv.service_dir}")
      end
    end # === def remove

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
end # === module DA
