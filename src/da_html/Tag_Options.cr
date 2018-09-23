
module DA_HTML
  struct Tag_Options

    AS_PATTERN         = /^([a-zA-Z\.\_\-0-9]+)(\ +AS\ +([a-z0-9\_\,\ ]+))?$/i
    getter name     : String  = ""
    getter as_name  : String? = nil
    getter cr_type  : String? = nil
    getter key_name : String? = nil
    getter origin   : Tag

    def initialize(@origin)
      str = @origin.attributes.keys.join(' ')
      is_valid = str.match(AS_PATTERN)

      if !is_valid
        raise Exception.new("Invalid option: <#{origin.tag_name} #{str.inspect}")
      end

      @name    = is_valid[1].not_nil!
      pieces   = if is_valid[3]?
                   is_valid[3].not_nil!.split(/\ *,\ */).compact.map(&.strip)
                 else
                   [] of String
                 end

      case pieces.size
      when 2
        @key_name = pieces.first
        @as_name = pieces.last
      when 1
        @as_name = pieces.last
      end
    end # def

    def raw
      "<#{origin.tag_name} #{origin.attributes.keys.join ' '}>"
    end # === def

    {% for x in "key_name as_name cr_type".split %}
      def {{x.id}}?
        !@{{x.id}}.nil?
      end

      def {{x.id}}!
        @{{x.id}}.not_nil!
      end
    {% end %}

    def invalid!(m : String)
      raise Exception.new("#{m}: #{raw}")
    end # === def

  end # === struct Collection_Options
end # === module DA_HTML
