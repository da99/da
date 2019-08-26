
require "./Geo"
require "./Xprop"

module DA

  class Window
    @@raw_list : String = ""

    # This value also keeps track of focus history.
    # Latest focused window starts at 0.
    @@list = Array(Window).new

    def self.to_geo(raw_id : String)
      id = clean_id(raw_id)
      x = y = w = h = 0
      `xwininfo -id #{id}`.each_line { |l|
        case
        when l["upper-left X"]?
          x = l.split(':').last.strip.to_i32
        when l["upper-left Y"]?
          y = l.split(':').last.strip.to_i32
        when l["Width: "]?
          w = l.split(':').last.strip.to_i32
        when l["Height: "]?
          h = l.split(':').last.strip.to_i32
        end # case
      }
      Geo.new(x: x, y: y, w: w, h: h)
    end # def

    def self.gap
      12
    end

    def self.border_width
      4
    end

    def self.terminal?(string)
      string["Xfce4-terminal"]?
    end

    def self.terminal_count
      `wmctrl -lx`.split('\n').select { |x| terminal?(x) }.size
    end

    def self.media_player?(classname_or_class : String)
      {"smplayer", "vlc", "mpv", "mplayer"}.includes?(classname_or_class)
    end # def

    def self.clean_id(raw : String)
      if raw['x']?
        "0x%08x" % raw.to_i(prefix: true)
      else
        "0x%08x" % raw.to_i32
      end
    end

    def self.focus_history
      current_ids = @@list.map { |x| x.id }
      Dawin::BSPC_History.node_ids.map { |id|
        if current_ids.includes?(id)
          id
        end
      }.compact
    end # def

    def self.focused
      @@list.find { |w| w.focused? }
    end # def

    def self.focused_window_id!
      raw = `xprop -root _NET_ACTIVE_WINDOW`.split.last || ""
      return nil unless (raw.index("0x") == 0)
      clean_id(raw)
    end

    def self.resize(geo)
      id = focused_window_id!
      if id
        resize(id, geo)
      else
        DA.inspect! "No focused window found for resizing."
      end
    end # def

    def self.resize(raw_id : String, geo)
      win_id = clean_id(raw_id)
      w = @@list.find { |w|
        if w.id == win_id
          w.resize geo
          true
        end
      }
      if !w
        DA.inspect! "--- Window with id #{raw_id.inspect} not found."
      end
      w
    end # def

    def self.update
      @@raw_list = `wmctrl -lxp`.strip

      ids = @@raw_list.lines.map { |x| clean_id(x.split.first) }
      old_ids = @@list.map { |w| w.id }
      @@list.each { |w|
        if !ids.includes?(w.id)
          @@list.delete w
          next
        end
      }

      @@raw_list.lines.each { |l|
        new_id = clean_id(l.split.first)
        if !old_ids.includes?(new_id)
          w = Window.new(new_id)
          @@list.unshift w
        end
      }


      focus_id = focused_window_id!
      @@list.each { |w|
        if w.id == focus_id
          w.is_focused!
        else
          w.not_focused!
        end
      }

      list
    end # def

    def self.list
      @@list
    end

    def self.sort_by_id
      @@list.sort { |a, b| a.id <=> b.id }
    end # def

    def self.groups
      sort_by_id.group_by { |w|
        w.class_
      }
    end # def

    def self.get_by_id(raw_id : String)
      id = clean_id(raw_id)
      w = @@list.find { |w| w.id == id }
      yield w if w
      w
    end

    # =============================================================================
    # Instance:
    # =============================================================================

    getter id        : String
    getter classname : String
    getter class_    : String
    getter desktop   : Int32
    getter pid       : Int32
    getter title     : String
    getter geo       : Geo? = nil
    getter spy_title : Xprop? = nil

    @is_focus        : Bool = false

    def initialize(raw_id : String)
      id = Window.clean_id(raw_id)

      raw = @@raw_list.lines.find { |l|
        l.index(id) == 0
      }.not_nil!

      match    = raw.match(/^(0x[^\ ]+)\ +(\d+)\ (\d+)\ +(.+)\ \ ([^\ ]+)\ (.+)$/).not_nil!
      pieces   = match.captures
      @id      = pieces.shift.not_nil!
      @desktop = pieces.shift.not_nil!.to_i32
      @pid     = pieces.shift.not_nil!.to_i32

      @classname, @class_ = pieces.shift.not_nil!.split('.').map(&.strip)
      pieces.shift # hostname
      @title = pieces.join(' ')
      if Window.media_player?(@class_)
        st = @spy_title = Xprop.new_spy_title(@id)
        spawn {
          while !st.process.terminated?
            x = st.read_title
            if x.is_a?(String)
              @title = x
            end
            sleep 0.1
          end
        }
      end

      @geo = begin
             g = Window.to_geo(@id)
             g.unknown? ? nil : g
           end # begin
    end # def

    # def close
    #   st = spy_title
    #   if st
    #     st.process.kill unless st.process.terminated?
    #   end
    # end

    def id?(raw_id : String)
      raw_id.downcase == id
    end

    def geo?
      !@geo.nil?
    end

    def geo_name
      g = @geo
      if g
        g.name
      else
        "Unknown"
      end
    end # def

    def is_focused!
      @is_focus = true
    end

    def not_focused!
      @is_focus = false
    end

    def focus!
      DA.run("wmctrl", "-i -a #{id}".split)
      is_focused!
    end

    def focused?
      @is_focus
    end

    def resize(g : Geo)
      @geo = g
      DA.inspect! "resizing #{id} #{g.inspect}"
      DA.run("wmctrl", "-i -r #{id} -e 0,#{g.x},#{g.y},#{g.w},#{g.h}".split)
      DA.run("wmctrl", "-i -r #{id} -e 0,#{g.x},#{g.y},#{g.w},#{g.h}".split)
      g
    end # def

    def media_player?
      Window.media_player?(class_)
    end # def

    def playing?
      return false unless media_player?
      case class_
      when "smplayer"
        title != "SMPlayer"
      when "vlc"
        title != "VLC media player"
      else
        false
      end
    end # def

  end # === class
end # === module
