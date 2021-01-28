
module DA_HTML::Base
    getter io : IO::Memory

    def initialize
      @io = IO::Memory.new
    end

    def text(raw : String)
      io << DA_HTML_ESCAPE.escape(raw)
    end # def

    def doctype!
      io << "<!DOCTYPE html>"
    end # def

    def html!
      doctype!
      html lang("en") do
        yield
      end
    end # === def

    def html(*args)
      open_tag(:html, *args)
      yield
      close_tag(:html)
    end # def

    {% for tag in "head".split.map(&.id) %}
      def {{tag}}
        open_tag(:{{tag}})
        yield
        close_tag(:{{tag}})
      end # === def
    {% end %}

    {% for tag in "title".split.map(&.id) %}
      def {{tag}}
        open_tag(:{{tag}})
        result = yield
        text(result) if result.is_a?(String)
        close_tag(:{{tag}})
      end # === def
    {% end %}

    {% for tag in "body p span div".split.map(&.id) %}
      def {{tag}}(*args)
        open_tag(:{{tag}}, *args)
        result = yield
        text(result) if result.is_a?(String)
        close_tag(:{{tag}})
      end # === def
    {% end %}

    def a(*raw)
      attrs  = Deque(Attribute).new
      rel    = Deque(String).new
      href   = nil

      raw.each { |attr|
        case attr
        when String
          attrs.concat Attribute.id_class(attr)
        when Attribute
          k = attr.name
          v = attr.value
          case k
          when :rel
            if v.is_a?(String)
              v.split.each { |x|
                case x
                when "external", "help", "prev", "next", "search", "nofollow", "noopener", "noreferrer"
                  rel.push x
                else
                  raise Attribute::Invalid_Value.new("<a #{k}=#{v.inspect}")
                end
              }
            end

          when :target
            case
            when v.is_a?(String) && {"_self", "_blank", "_parent", "_top"}.includes?(v)
              target = v
              attrs << Attribute.new(k, v)
            else
              raise Attribute::Invalid_Value.new("<a #{k}=#{v.inspect}")
            end

          when :href
            if v.is_a?(String)
              href = DA_URI.clean(v)
              if href.is_a?(String)
                attrs << Attribute.new(k, href)
              end
            end

          else
            raise Attribute::Invalid_Value.new("<a #{k}=#{v.inspect}")

          end # case
        end # case attr
      }

      if !href || href.strip.empty?
        raw_href = raw.find { |x| x.is_a?(Attribute) && x.name == :href }
        if raw_href.is_a?(Attribute)
          raise Attribute::Invalid_Value.new(%[attribute for 'a' tag has an invalid URL: #{raw_href.value.inspect}.])
        else
          raise Attribute::Invalid_Value.new(%[attribute for 'a' tag was not specified.])
        end
      end

      A_REL_COMMON.each { |x|
        if !rel.includes?(x)
          rel.push x
        end
      }
      attrs << Attribute.new(:rel, rel.join(' '))

      tag(:a, attrs) {
        result = yield
        text(result) if result.is_a?(String)
      }
    end # def

    {% for attr in "rel target lang id class_".split.map(&.id) %}
      def {{attr}}(x : String)
        Attribute.new(:{{attr.gsub(/_+$/, "")}}, x)
      end
    {% end %}


    def href(raw : String)
      clean = DA_URI.clean(raw)
      if clean
        Attribute.new(:href, clean)
      else
        raise Attribute::Invalid_Value.new("URL is invalid: #{raw.inspect}")
      end
    end # def

    def local_href(raw : String)
      valid_chars = raw.chars.all? { |c|
        case c
        when 'a'..'z', '0'..'9', '.', '-', '_', '/', '?', '='
          true
        else
          false
        end
      }

      if raw[0]? != '/' || !valid_chars
        raise Attribute::Invalid_Value.new("URL not local: #{raw.inspect}")
      end

      href(raw)
    end # def

    {% for x in "name content".split.map(&.id) %}
      def {{x}}(s : String)
        DA_HTML::Attribute.new(:name, s)
      end # def
    {% end %}

    def meta_utf8
      tag(
        :meta,
        DA_HTML::Attribute.new(:"http-equiv", "Content-Type"),
        content("text/html; charset=UTF-8")
      )
    end # def

    def <<(x : String)
      io << x
      io
    end # === def

    def attribute(a : Attribute)
      val = a.value
      if val.is_a?(Nil)
        io << ' ' << a.name
      else
        io << ' ' << a.name << '=' << DA_HTML_ESCAPE.escape(a.value.to_s).inspect
      end
    end # def

    def tag(tag_name : Symbol, *args)
      open_tag(tag_name, *args)
      yield
      close_tag(tag_name)
      io
    end # def

    def tag(tag_name : Symbol, *args)
      open_tag(tag_name, *args)
      io
    end # def

    def open_tag(tag_name : Symbol, *args)
      io << '<' << tag_name
      args.each_with_index { |x, i|
        case x
        when String
          Attribute.id_class(x).each { |x|
            attribute x
          }
        when Attribute
          attribute x
        else
          x.each { |x2| attribute x2 }
        end
      }
      io << '>'
      io
    end # def

    def close_tag(tag_name : Symbol)
      io << '<' << '/' << tag_name << '>'
      io
    end # def

    def void_tag(tag_name, *args)
      open_tag(tag_name, *args)
      io
    end # === def

    def link_main_css
      io << %(\n<link href="/main.css" rel="stylesheet">)
    end # def

    def script_main_js
      io << %(\n<script src="/main.js" type="application/javascript"></script>)
    end # def

    {% for x in "nofollow noreferrer noopener".split.map(&.id) %}
      def {{x}}
        Attribute.new(:{{x}})
      end
    {% end %}

    def to_s(io_)
      io_ << @io
    end
end # === module DA_HTML::Base
