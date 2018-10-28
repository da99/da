
require "da_html_escape"
require "da"

module DA
  def strip_each_line(s : String)
    s.strip.lines.map { |x| x.strip }.join('\n')
  end # def
end # === module DA

module DA_HTML

  extend self

  def known_tag?(tag_name : Symbol)
    { :html, :link, :meta, :base, :style, :title,
      :body, :address, :article, :aside, :footer, :header,
      :h1, :h2, :h3, :h4, :h5, :h6,
      :hgroup, :nav, :section, :blockquote,
      :dd, :dir, :div, :dl, :dt, :figcaption, :figure,
      :hr, :li, :main, :ol, :p, :pre, :ul, :a, :abbr,
      :b, :bdi, :bdo, :br, :cite, :code, :data,
      :dfn, :em, :i, :kbd, :mark, :q, :rb, :rp,
      :rt, :rtc, :ruby, :s, :samp,
      :small, :span, :strong, :sub, :sup, :time, :tt,
      :u, :var, :wbr,
      :noscript, :script,
      :del, :ins, :caption,
      :col, :colgroup, :table, :tbody, :td,
      :tfoot, :th, :thead, :tr, :button,
      :datalist, :fieldset, :form, :input,
      :label, :legend, :meter, :optgroup, :option,
      :output, :progress, :select, :textarea, :details,
      :dialog, :menu, :menuitem, :summary }.includes? tag_name
  end # def

  def void?(tag_name : Symbol)
    {:area, :base, :br, :col, :command, :embed,
     :hr, :img, :input, :keygen, :link, :meta,
     :param, :source, :track, :wbr}.includes? tag_name
  end # === def

  def prettify(str : String)
    indent = 0
    str.gsub( /\>\<([a-z\/])/ ) { |s, x|
      case x[1]
      when "/"
        indent -= 1
        ">\n#{" " * (indent)}</"
      else
        indent += 1
        ">\n#{" " * indent}<#{x[1]}"
      end
    }
  end # === def pretty_html

  struct HTML_Attribute
    def self.id_class(raw : String)
      in_id   = false
      attrs   = Deque(HTML_Attribute).new
      id      = Deque(Char).new
      class_  = Deque(Char).new

      raw.each_char { |c|
        case c
        when '#'
          in_id = true
        when '.'
          in_id = false
          (class_ << ' ') unless class_.empty?
        else
          (in_id ? id : class_) << c
        end
      }

      if !id.empty?
        attrs << HTML_Attribute.new(:id, id.join)
      end

      if !class_.empty?
        attrs << HTML_Attribute.new(:class, class_.join)
      end

      attrs
    end # def

    getter name : Symbol
    getter value : String

    def initialize(@name, @value)
    end
  end # === module HTML_Attribute

  module Base

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

    {% for attr in "lang id class_".split.map(&.id) %}
      def {{attr}}(x)
        HTML_Attribute.new(:{{attr.gsub(/_+$/, "")}}, x)
      end
    {% end %}

    def <<(x : String)
      io << x
      io
    end # === def

    def attribute(a : HTML_Attribute)
      io << ' ' << a.name << '=' << a.value.inspect
    end # def

    def open_tag(tag_name : Symbol, *args)
      io << '<' << tag_name
      args.each_with_index { |x, i|
        case x
        when String
          HTML_Attribute.id_class(x).each { |x|
            attribute x
          }
        when HTML_Attribute
          attribute x
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

    def to_s(io_)
      io_ << @io
    end
  end # === module Base

  struct Page
    include Base
  end # === struct Page

  def to_html
    page = Page.new
    with page yield
    page.io
  end # === def

end # === module DA_HTML


