
module DA_HTML

  struct Page

    @io = IO::Memory.new
    @tags = Deque(String).new
    getter validator : Validator

    def initialize(@validator)
    end # === def initialize

    def to_html
      @io.to_s
    end

    def validate_attr!(name)
      result = validator.attr!(self, @tags.last, name)
      case
      when result == true
        name
      else
        raise Invalid_Attr.new("#{@tags.last.inspect} #{name.inspect}")
      end
    end # === def validate_attr

    def validate_attr!(name, val)
      result = validator.attr!(self, @tags.last, name, val)
      case
      when result == true
        DA_HTML_ESCAPE.escape(val.to_s)
      when result.is_a?(String)
        DA_HTML_ESCAPE.escape(result)
      else
        raise Invalid_Attr.new("#{@tags.last.inspect} #{name.inspect}=#{val.inspect}")
      end
    end # === def validate_attr

    def write_attr(name : Symbol | String)
      raw! ' '
      raw! { |io|
        validate_attr!(name).to_s(io)
      }
      self
    end # === def write_attr

    def write_attr(name : Symbol | String, raw_val : String | Symbol | Int32)
      raw! ' '
      raw! { |io|
        name.to_s(io)
        io << '='
        validate_attr!(name, raw_val).inspect(io)
      }
      self
    end # === def write_attr

    def write_id_class(x : String)
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
    end # === def raw!

    def raw!
      yield @io
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

    def head(*args)
      open_and_close_tag("head", *args) {
        with self yield
      }
    end # === def head

    def doctype!
      raw! "<!DOCTYPE html>"
    end # === def doctype

    def text(raw : String)
      @io << raw
    end # === def text

    def open_and_close_tag(name : String, *args, **attrs)
      @tags.push name
      @io << '<' << name
      args.each { |x|
        case x
        when String
          write_id_class(x)
        else
          raise Error.new("Unknown arg for tag: #{x.inspect}")
        end
      }

      attrs.each { |k, v| write_attr k, v }

      @io << '>'
      result = with self yield
      case result
      when String
        text result
      end
      @io << '<' << '/' << name << '>'
      @tags.pop
      self
    end # === def open_and_close_tag

    def closed_tag(name : String, *args)
      @tags.push name
      raw! '<'
      raw! name
      args.each { |a|
        case a.size
        when 1
          write_attr(a.first)
        when 2
          write_attr(a.first, a.last)
        else
          raise Error.new("Invalid attribute: #{a.inspect}")
        end
      }
      raw! '>'
      @tags.pop
    end # === def closed_tag

    {% for x in %w[p div span] %}
      def {{x.id}}(*args, **attrs)
        open_and_close_tag({{x.id.stringify}}, *args, **attrs) {
          with self yield
        }
      end # === def {{x.id}}
    {% end %}

    def title
      open_and_close_tag("title") {
        with self yield
      }
    end # === def title

    def strong(content : String)
      open_and_close_tag("strong") {
        text content
      }
    end # === def strong

    def body(*args)
      open_and_close_tag("body", *args) {
        with self yield
      }
    end # === def body

  end # === struct Page

end # === module DA_HTML
