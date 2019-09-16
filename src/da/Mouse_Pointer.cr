
module DA
  struct Mouse_Pointer
    getter x = 0
    getter y = 0
    getter screen = 0
    def initialize
      `xdotool getmouselocation --shell`.strip.lines.each { |l|
        pieces = l.split('=')
        case pieces.first
        when "X"
          @x = pieces.last.to_i
        when "Y"
          @y = pieces.last.to_i
        when "SCREEN"
          @screen = pieces.last.to_i
        end
      }
    end # def
  end # === struct
end # === module
