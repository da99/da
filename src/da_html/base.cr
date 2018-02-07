
module DA_HTML

  module Base_Class

    # def to_html(*args)
    #   page = new(*args)
    #   page.to_html { |p|
    #     with p yield p
    #   }
    #   page.to_html
    # end

  end # === module Base_Class

  module Base

    macro included
      extend ::DA_HTML::Base_Class
    end

    macro to_html(*args, &blok)
      {{@type}}.new({{*args}}).to_html {{blok}}
    end

    protected getter io = IO::Memory.new
    @tags = Deque(String).new

    def initialize
    end # === def initialize

    def initialize(page : DA_HTML::Base)
      @io = page.io
    end # === def initialize

    def to_html
      with self yield self
      self.to_html
    end

    def to_html
      @io.to_s
    end

    def tag!(page, tag_name)
      tag_name.each_char { |c|
        case c
        when 'a'..'z', '_', '-'
          true
        else
          return false
        end
      }
      true
    end

    def attr!(page, tag_name, name : Symbol, val)
      case name
      when :id, :class
        return true
      end

      case
      when tag_name == "a" && name == :href
        return(DA_URI.clean(val) || "#invalid_url")
      end

      false
    end # === def self.attr?

    def attr!(page, tag_name, name)
      case name
      when :required
        true
      else
        false
      end
    end # === def self.attr?

    def validate_attr!(name)
      result = attr!(self, @tags.last, name)
      case
      when result == true
        name
      else
        raise Invalid_Attr.new("#{@tags.last.inspect} #{name.inspect}")
      end
    end # === def validate_attr

    def validate_attr!(name, val)
      result = attr!(self, @tags.last, name, val)
      case
      when result == true
        DA_HTML_ESCAPE.escape(val.to_s)
      when result.is_a?(String)
        DA_HTML_ESCAPE.escape(result)
      else
        raise Invalid_Attr.new("#{@tags.last.inspect} #{name.inspect}=#{val.inspect}")
      end
    end # === def validate_attr

    def validate_tag!(name)
      result = tag!(self, name)
      case result
      when true
        return name
      else
        raise Invalid_Tag.new(name.inspect)
      end
    end # === def validate_tag!

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
        io << '=' << '"'
        validate_attr!(name, raw_val).to_s(io)
        io << '"'
      }
      self
    end # === def write_attr

    def write_tag(name : String)
      raw! { |io|
        validate_tag!(name).to_s(io)
      }
    end # === def write_tag

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
      @io << '<'
      write_tag name
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

    def a(*args, **attrs)
      open_and_close_tag("a", *args, **attrs) {
        with self yield
      }
    end # === def a

  end # === module Base

end # === module DA_HTML
