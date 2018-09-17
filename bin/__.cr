
require "myhtml"
require "da"

html = File.read("extra/sample.html")

module DA_HTML

  extend self

  def text?(x : Myhtml::Node)
    x.tag_name == "-text"
  end

  def to_tag(n : Myhtml::Node, index = 0) : Text | Tag
    if text?(n)
      Text.new(n, index: index)
    else
      a = {} of String => Int32 | Int64 | String
      c = [] of Tag | Text
      n.attributes.each { |k, v|
        case v
        when Int32 | Int64 | String
          a[k] = v
        else
          raise Exception.new("Unknown attribute for #{n.tag_name}: #{k.inspect}=#{v.inspect}")
        end
      }
      n.children.each_with_index { |y, i|
        c.push DA_HTML.to_tag(y, index: i)
      }
      Tag.new(n.tag_name, a, children: c, index: index)
    end
  end

  struct Text

    getter tag_text : String
    getter index = 0

    def initialize(n : Myhtml::Node, @index = 0)
      @tag_text = n.tag_text
    end # === def

    def initialize(@tag_text, @index = 0)
    end # === def

    def empty?
      @tag_text.strip.empty?
    end

    def to_html
      @tag_text
    end

    def text?
      true
    end

    def tag_text(s : String)
      @tag_text = s
    end

    def map_walk!(&blok : Text | Tag -> Text | Tag | Nil)
      blok.call self
    end # === def

  end # === struct Text

  struct Tag

    # =============================================================================
    # Instance:
    # =============================================================================

    getter tag_name : String
    getter attributes = {} of String => Int32 | Int64 | String
    getter children   = [] of Tag | Text
    getter index      = 0

    @end_tag : Bool

    def initialize(node : Myhtml::Node, @index = 0)
      @tag_name = node.tag_name
      @end_tag = case @tag_name
                 when "input"
                   false
                 else
                   true
                 end
      node.attributes.each { |k, v| @attributes[k] = v }
      node.children.each { |c| @children.push DA_HTML.to_tag(c) }
    end # === def

    def initialize(@tag_name : String, attributes, children : Array(Tag | Text)? = nil, end_tag : Bool? = true, text : String? = nil, @index = 0)
      if attributes
        attributes.each { |k, v| @attributes[k] = v }
      end

      if children
        children.each { |c| @children.push c }
      end

      if text
        @children.push Text.new(text)
      end

      @end_tag = end_tag
    end # === def

    def end_tag?
      @end_tag
    end

    def empty?
      children.empty?
    end

    def text?
      false
    end

    def map_walk!(&blok : Text | Tag -> Text | Tag | Nil)
      result = blok.call(self)
      case result
      when Tag
        new_children = [] of Text | Tag
        result.children.each { |c|
          r = c.map_walk!(&blok)
          case r
          when Tag, Text
            new_children.push r
          end
        }
        @tag_name = result.tag_name
        @attributes = result.attributes
        @children = new_children
        return self
      end
      result
    end # === def

    def to_html
      io = IO::Memory.new
      io << "<#{tag_name}"
      attributes.each { |k, v|
        io << ' ' << k << '=' << '"' << v.inspect << '"'
      }
      io << '>'
      if end_tag?
        io << "</#{@tag_name}>"
      end
      io.to_s
    end

  end # === struct Tag

  class Tags

    def self.walk(t)
      yield t
      if t.is_a?(Tag)
        t.children.each { |c|
          walk(c)
        }
      end
    end # === def

    getter raw    : String
    getter tags  = [] of Tag | Text
    include Enumerable(DA_HTML::Tag | DA_HTML::Text)

    def initialize(raw : String)
      @raw = raw.gsub(/\<=([\ a-zA-Z0-9\.\_\-]+)\>/) { |x, y|
        "<var #{y[1]}></var>"
      }
      Myhtml::Parser.new(@raw).body!.children.each { |node|
        tags.push DA_HTML.to_tag(node)
      }
    end # === def

    def each
      tags.each { |x| yield x }
    end

    def map_walk!(&blok : Text | Tag -> Text | Tag | Nil)
      new_tags = [] of Tag | Text
      tags.each { |t|
        result = t.map_walk! { |t2| blok.call(t2) }
        case
        when result.is_a?(Tag) || result.is_a?(Text)
          new_tags.push result
        when result == :remove
          nil
        end
      }
      @tags = new_tags
    end

  end # === class Tags

  module Cleaner
    def clean(x) : Tag | Symbol
      raise Exception.new("Not implemented: #{self.to_s}.clean")
    end
  end # === struct Cleaner

  struct JS_Template

    getter tags   : Tags
    getter io     : IO::Memory = IO::Memory.new
    getter pieces : Deque(String) = Deque(String).new
    getter levels : Deque(Int32) = Deque(Int32).new

    def initialize(x : String)
      @tags = Tags.new(x)
    end # def

    def initialize(@tags)
    end # === def

    def append_to_io(x : String)
      io << spaces << "io += " << x << ";\n"
      io
    end # === def

    def indent
      levels.push 1
      yield
      levels.pop
    end # === def

    def spaces
      "  " * levels.size
    end # === def

    def var(x : String)
      x.gsub(/[^a-zA-Z0-9\-]/, "_")
    end

    def print_var(x : String, y : String)
      io << spaces << "var " << var(x) << " = " << y << ";\n"
      io
    end # === def

    def let(x : String, y : String)
      io << spaces << "let " << var(x) << " = " << y << ";\n"
      io
    end # === def

    def print(x : String)
      io << spaces << x
      io
    end

    def print_line(x : String)
      io << spaces << x << ";\n"
      io
    end # === def

    def print_x(x)
      case x
      when DA_HTML::Text
        return if x.empty?
        append_to_io x.tag_text.inspect
        return
      end

      if x.tag_name == "var"
        var_name = x.attributes.keys.join(' ')
        append_to_io "#{var_name}.toString()"
        return
      end

      if x.tag_name == "object"
        raw_attrs = x.attributes.keys.join(' ').split(/[\ |,]+/)
        coll_name = raw_attrs.shift
        if !(raw_attrs.shift == "as")
          raise Exception.new("Invalid: <object #{x.attributes.keys.join ' '}>")
        end

        case raw_attrs.size
        when 2
          key_name, var_name = raw_attrs
        when 1
          key_name = "#{coll_name}_k"
          var_name = var(raw_attrs.last)
        else
          raise Exception.new("Invalid: <object #{x.attributes.keys.join ' '}>")
        end # case

        print "for (let #{key_name} in #{coll_name}) {\n"
        indent {
          print "let #{var_name} = #{coll_name}[#{key_name}];\n"
          x.children.each { |y| print_x(y) }
        }
        print "}\n"

        return
      end # if x.tag_name == "object"

      if x.tag_name == "array"
        coll = x.attributes.keys.first
        var_name = x.attributes.keys.last
        length = var(coll) + "_length"
        i = var(coll) + "_i"
        let length, "#{coll}.length"
        print "for(let #{i} = 0; #{i} < #{length}; ++#{i}) {\n"
        indent {
          let var_name, "#{coll}[#{i}]"
          x.children.each { |y| print_x(y) }
        }
        print "}\n"
        return
      end

      append_to_io "<#{x.tag_name} #{x.attributes.map { |k, v| "#{k}=\"#{v}\"" }.join ' '}>".inspect
      indent {
        x.children.each { |y|
          print_x(y)
        }
      }
      if x.end_tag?
        append_to_io "</#{x.tag_name}>".inspect
      end
    end

    def to_js
      return io.to_s unless io.empty?
      io << "function template(data) {\n"
      indent {
        let "io", "\"\""
        tags.each { |x|
          print_x(x)
        }
        print "return io;\n"
      }
      io << "}\n"
      to_js
    end # === def

  end # === struct JS_Template
end # === module DA_HTML

module Upcase_HREF
  extend self
  def clean(t)
    case
    when t.is_a?(DA_HTML::Tag) && t.tag_name == "a"
      return DA_HTML::Tag.new(tag_name: "a", attributes: {"href"=>"/UPCASE"}, text: "done")
    end
    return t
  end
end # === class Upcase_HREF

module Clean_First_Text
  extend self
  def clean(t)
    case
    when t.is_a?(DA_HTML::Text) && t.index == 0
      t.tag_text t.tag_text.lstrip
      return t
    end
    return t
  end # === def
end # === module Clean_First_Text

tags = DA_HTML::Tags.new(html)
tags.map_walk! { |n|
  Upcase_HREF.clean(
    Clean_First_Text.clean(
      n
    )
  )
}

js_template = DA_HTML::JS_Template.new(tags)
# puts js_template.to_js
File.write(
  "tmp/a.js",
  <<-JS
    #{js_template.to_js}
    {
      let data = {persons : [{name: "Phil", addresses: [{location: "Mongo City", planet: "Main Mongo"}, {location: "Star City", planet: "Earth"}]}]};
      let s = template(data);
      console.log(data);
      console.log(s);
    }
  JS
)
Process.exec("node", "tmp/a.js".split)

