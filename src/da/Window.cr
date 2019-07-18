
require "./Geo"
require "./Xprop"

module DA

  class Window
    @@raw_list : String = ""

    # This value also keeps track of focus history.
    # Latest focused window starts at 0.
    @@list = Array(Window).new

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

    def self.clean_id(raw_id : String)
      raw_id.downcase
    end

    def self.focus
      @@list.find { |w| w.focus? }
    end # def

    def self.focus_history
      current_ids = @@list.map { |x| x.id }
      Dawin::BSPC_History.node_ids.map { |id|
        if current_ids.includes?(id)
          id
        end
      }.compact
    end # def

    def self.focus(raw_id : String)
      w_id = clean_id(raw_id)
      window = nil
      target_index = nil
      @@list.each_with_index { |w, i|
        if w.id?(raw_id)
          w.focus
          target_index = i
          window = w
        else
          w.unfocus
        end
      }

      # Put focused window on top.
      if target_index
        @@list.rotate! target_index
      end

      window
    end # def

    def self.resize(geo)
      resize(Dawin::Root.new.active_window_id, geo)
    end # def

    def self.resize(raw_id : String, geo)
      win_id = clean_id(raw_id)
      @@list.find { |w|
        if w.id == win_id
          w.resize geo
        end
      }
    end # def

    def self.update
      @@raw_list = `wmctrl -lxp`.strip
      ids = @@raw_list.lines.map { |x| clean_id(x.split.first) }
      old_ids = @@list.map { |w| w.id }
      @@list.each { |w|
        if !ids.includes?(w.id)
          @@list.delete w
        end
      }

      @@raw_list.lines.each { |l|
        new_id = clean_id(l.split.first)
        if !old_ids.includes?(new_id)
          w = Window.new(new_id)
          @@list.unshift w
        end
      }

      list
    end # def

    Window.update

    def self.list
      @@list
    end

    def self.sort_by_id
      @@list.sort { |a, b| a.id <=> b.id }
    end # def

    def self.grouped_by_class_
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
      id = raw_id.downcase
      raw = @@raw_list.lines.find { |l|
        l.index(id) == 0
      }.not_nil!
      pieces = raw.split
      @id = pieces.shift
      @desktop = pieces.shift.to_i32
      @pid = pieces.shift.to_i32
      @classname, @class_ = pieces.shift.split('.')
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
    end # def

    def close
      st = spy_title
      if st
        st.process.kill unless st.process.terminated?
      end
    end

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

    def focus
      @is_focus = true
    end

    def unfocus
      @is_focus = false
    end

    def focus?
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
