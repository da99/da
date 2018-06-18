
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

    def initialize
      @dir  = Dir.current
      @name = File.basename(@dir)
    end # === def initialize

    def initialize(@name)
      @dir = case
             when DA.is_test?
               File.join("/tmp/specs_deploy", @name)
             when DA.is_development?
               File.join("/apps", @name)
             else
               File.join("/deploy", @name)
             end
    end # === def initialize

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

    def dir(*args)
      File.join(@dir, *args)
    end # === def dir

    def current
      File.join dir, "current"
    end

    def current!
      latest = Release.latest(self)
      if latest
        DA.link_symbolic! latest, current
        return true
      else
        DA.exit_with_error! "!!! Latest release for #{name} not found."
      end
    end

  end # === struct App
end # === module DA
