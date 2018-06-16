
module DA
  struct PG

    getter name : String
    getter app  : App
    getter linked_dir : String
    getter latest : String?

    def initialize(@name)
      @app        = App.new(@name)
      @linked_dir = @app.dir("pg")
      @latest     = __latest = @app.latest("pg")
      @is_exist   = !!(__latest && File.directory?(__latest))
    end # === def initialize

    def user
      "pg-#{name}"
    end

    def group_socket
      "socket-#{name}"
    end

    def exists?
      @is_exist
    end

    def link!
      `ln -sf #{latest} #{linked_dir}`
    end # === def link!

  end # === struct PG
end # === module DA
