
module DA_HTML

  module Base

    include DA_Helpers

    include HEAD::Tag
    include BODY::Tag
    include DIV::Tag
    include SPAN::Tag
    include TITLE::Tag
    include STRONG::Tag
    include A::Tag
    include P::Tag
    include INPUT_TEXT::Tag

    macro included
      extend Class_Methods
    end

    module Class_Methods
      def to_html
        page = new
        with page yield page
        page.to_html
      end

      def partial(*args)
        page = new(*args)
        with page yield page
        nil
      end
    end # === module Class_Methods

    protected getter io = IO::Memory.new
    @is_partial = false

    def initialize
    end # === def initialize

    def initialize(page : DA_HTML::Base)
      @io = page.io
      @is_partial = true
    end # === def initialize

    def is_partial?
      @is_partial
    end

    # NOTE: returns nil if page is a partial (i.e. .new(Some_Page))
    def to_html
      with self yield self
      self.to_html unless is_partial?
    end

    def to_html
      @io.to_s
    end

    def id_class!(x : String)
      id      = Deque(Char).new
      class_  = nil
      classes = Deque(Deque(Char)).new
      is_writing_to = :none
      x.each_char { |c|
        case c
        when '#'
          is_writing_to = :id
        when '.'
          is_writing_to = :class
          if class_ && !class_.empty?
            classes.push class_
          end
          class_ = Deque(Char).new
        when 'a'..'z', '0'..'9', '_'
          case is_writing_to
          when :id
            id.push c
          when :class
            if class_
              class_.push c
            end
          else
            raise Error.new("Invalid id/class: #{x.inspect}")
          end
        else
          raise Error.new("Invalid char for id/class: #{c.inspect} in #{x.inspect}")
        end
      }
      if class_ && !class_.empty?
        classes.push class_
        class_ = nil
      end

      if !id.empty?
        raw! %[ id="]
        id.each { |c| raw! c }
        raw! '"'
      end
      if !classes.empty?
        raw! %[ class="]
        classes.each_with_index { |klass, i|
          raw! ' ' if i != 0
          klass.each { |c| raw! c }
        }
        raw! '"'
      end
      self
    end # === def write_id_class

    def raw!(*raws)
      raws.each { |s| @io << s }
      self
    end # === def raw!

    def raw!
      yield @io
      self
    end

    def attr!(k : Symbol)
      raw!(' ') << k
      nil
    end

    def attr!(k : Symbol, v : Int32)
      raw!(' ') << k << '=' << '"' << v << '"'
      nil
    end # === def attr!

    def attr!(k : Symbol, v : String)
      raw!(' ') << k << '=' << '"' << DA_HTML_ESCAPE.escape(v) << '"'
      nil
    end # === def attr!

    def attr!(k : Symbol, v : Deque(String))
      raw!(' ') << k << '=' << '"'
      v.each_with_index { |x, i|
        raw! ' ' if i > 0
        raw! DA_HTML_ESCAPE.escape(x)
      }
      raw!('"')
      nil
    end # === def attr!

    def attrs!(x)
      x.each { |k, v|
        attr! k, v
      }
      nil
    end

    def <<(x : Symbol | String | Char | Int32)
      raw! x
    end

    def html(args = nil)
      if !args
        raw! %[<html lang="en">]
        with self yield
        raw! %[</html>]
      else
        open_and_close_tag("html", args) {
          with self yield
        }
      end
    end # === def html

    def doctype!
      raw! "<!DOCTYPE html>"
    end # === def doctype

    def text?
      x = with self yield self
      if x.is_a?(String)
        text! x 
        return true
      end
      false
    end

    def text!(raw : String)
      @io << DA_HTML_ESCAPE.escape(raw)
    end # === raw_def text

    def tag(*args, **attrs)
      name = args.first
      tag(*args, **attrs)
      text? {
        with self yield self
      }
      raw! "</#{name}>"
    end # === def tag

    def tag(*args, **attrs)
      name = args.first
      raw! "<#{name}"
      used_id_class = false
      args.each_with_index { |x, i|
        next if i.zero?
        case
        when x.is_a?(String) && !used_id_class
          id_class!(x)
          used_id_class = true
        when x.is_a? Symbol
          attr! x
        else
          raise Invalid_Attr.new(x.inspect)
        end
      }
      attrs! attrs
      raw! ">"
    end
  end # === module Base

end # === module DA_HTML
