
module DA
  class Window

    struct Geo

      LIST = [] of Geo

      def self.list
        LIST
      end # def

      def self.to_geo(raw_name : String)
        list.find { |g| g.name == raw_name }
      end # def

      def self.to_geo(x, y, w, h)
        g = list.find { |g|
          g.x == x &&
            g.y == y &&
            g.w == w &&
            g.h == h
        }
        g
      end # def

      getter x    : Int32
      getter y    : Int32
      getter w    : Int32
      getter h    : Int32
      getter name : String = "Unknown"

      def initialize(@x,@y,@w,@h, @name = "Unknown")
        if @name == "Unknown"
          g = Geo.to_geo(@x, @y, @w, @h)
          @name = g.name if g
        end
      end # def

      def edge_x
        x + w + Window.gap
      end # def

      def edge_y
        y + h + (Window.border_width * 2) + Window.gap
      end # def

      def unknown?
        @name == "Unknown"
      end

    end # === struct
  end # class Window
end # === module
