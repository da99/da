
module DA_HTML

  struct Tag

    getter page : DA_HTML::Base
    getter tag_name : Symbol
    getter id       : Deque(Char)
    getter _class   : Deque(Char)
    getter attrs    : String
    getter single_attrs = Deque(Symbol).new

    def initialize(@page, @tag_name, *args, **attrs)
      args.each { |x|
        case x
        when String
          id_class = page.split_id_class(x)
          @id = id_class.first
          @_class = id_class.last
        when Symbol
          single_attrs.push
        else
          raise Invalid_Attr_Value.new("#{@tag_name.inspect} #{x.inspect}")
        end
      }
      @attrs = attrs
    end # === def initialize

    def to_s(io)
      io << '<'
      page.write_tag(tag_name)
      unless @id.empty?
        io << " id=\""
        @id.each { |x| io << x }
        io << "\""
      end
      unless @_class.empty?
        io << " class=\""
        @id.each { |x| io << x }
        io << "\""
      end
      attrs.each { |k, v|
        page.write_attr k, v
      }
      io << '>'
    end # === def to_s

  end # === struct Tag

end # === module DA_HTML
