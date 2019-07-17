
module DA
  class Window

    struct Geo
      getter x : Int32
      getter y : Int32
      getter w : Int32
      getter h : Int32
      getter name : String = "Unknown"

      def initialize(@x,@y,@w,@h,@name = "Unknown" )
      end

      def edge_x
        x + w + Window.gap
      end # def

      def edge_y
        y + h + (Window.border_width * 2) + Window.gap
      end # def

    end # === struct
  end # class Window
end # === module
