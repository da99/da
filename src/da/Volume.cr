
module DA
  def volume_master
    Volume.new(`amixer get Master`)
  end

  struct Volume
    getter raw : String
    getter num : Int32 = 0
    getter status  : String = "?"

    def initialize(@raw : String)
      m = @raw.match(/\[(\d+)\%\] \[([^\]]+)\]/)
      if m
        @num    = m[1].to_i
        @status = m[2]
      end
    end # def

    def on?
      @status == "on"
    end
  end # === struct
end # === module
