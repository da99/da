
require "myhtml"
require "da"

html = File.read("extra/sample.html")

module DA_HTML

  alias Node = Text | Tag
  alias Attribute_Value = Int32 | Int64 | String

  extend self

  def text?(x : Myhtml::Node)
    x.tag_name == "-text"
  end

  def to_tag(n : Myhtml::Node, parent : Tag?, index : Int32) : Node
    if text?(n)
      return Text.new(n, parent: nil, index: index)
    end

    a = {} of String => Attribute_Value
    n.attributes.each { |k, v|
      case v
      when Attribute_Value
        a[k] = v
      else
        raise Exception.new("Unknown attribute for #{n.tag_name}: #{k.inspect}=#{v.inspect}")
      end
    }
    t = Tag.new(n.tag_name, index: index, attributes: a)

    n.children.each_with_index { |y, i|
      t.children.push DA_HTML.to_tag(y, parent: t, index: i)
    }
    t
  end # def

  class Text

    getter tag_text : String
    getter index = 0
    getter parent : Tag? = nil

    def initialize(n : Myhtml::Node, @parent, @index)
      @tag_text = n.tag_text
    end # === def

    def initialize(@tag_text, @parent, @index)
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

    def map_walk!(&blok : Node -> Node | Nil)
      blok.call self
    end # === def

  end # === struct Text

  class Tag

    # =============================================================================
    # Instance:
    # =============================================================================

    getter tag_name : String
    getter parent   : Tag? = nil
    getter index      = 0
    getter attributes = {} of String => Attribute_Value
    getter children   = [] of Tag | Text

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
      node.children.each_with_index { |c, i| @children.push DA_HTML.to_tag(c, parent: self, index: i) }
    end # === def

    def initialize(
      @tag_name : String,
      @index,
      attributes,
      children : Array(Tag | Text) = [] of Tag | Text,
      @end_tag : Bool = true,
      text : String? = nil,
    )
      if attributes
        attributes.each { |k, v| @attributes[k] = v }
      end

      if children
        children.each { |c| @children.push c }
      end

      if text
        @children.push Text.new(text, parent: self, index: children.size)
      end
    end # === def

    def attributes(x)
      @attributes = {} of String => Attribute_Value
      x.each { |k, v|
        @attributes[k] = v
      }
      @attributes
    end # === def

    def tag_text
      if children.empty?
        nil
      else
        children.first.tag_text
      end
    end

    def tag_text(s : String)
      if children.size == 1
        children.pop
      end
      children.push Text.new(s, parent: self, index: children.size)
      @children
    end # def

    def end_tag?
      @end_tag
    end

    def empty?
      children.empty?
    end

    def text?
      false
    end

    def map_walk!(&blok : Node -> Node | Nil)
      result = blok.call(self)
      case result
      when Tag
        new_children = [] of Node
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
      Myhtml::Parser.new(@raw).body!.children.each_with_index { |node, i|
        tags.push DA_HTML.to_tag(node, parent: nil, index: i)
      }
    end # === def

    def each
      tags.each { |x| yield x }
    end

    def map_walk!(&blok : Node -> Node | Nil)
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

  struct Collection_Options

    getter name : String
    getter origin : Tag
    @as : String? = nil
    getter vars = [] of String

    def initialize(x)
      @origin = x
      pieces = x.attributes.keys.join(' ').split(/[\ ,]+/)
      @name = pieces.shift
      @as = (pieces.first? == "as") ? pieces.shift : nil
      @vars = pieces
    end # def

    def has_vars
      @as
    end

    def invalid!
      raise Exception.new("Invalid: <#{origin.tag_name} #{origin.attributes.keys.join ' '}> #{vars.inspect}")
    end # === def

  end # === struct Collection_Options

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

    def print_children(x)
      x.children.each { |y|
        print_x(y)
      }
    end # === def

    def print_block(s : String)
      print "#{s} {\n"
      indent {
        yield
      }
      print "} // #{s}\n"
    end

    def print_x(x)
      case x

      when DA_HTML::Text
        return if x.empty?
        append_to_io x.tag_text.inspect
        return

      when DA_HTML::Tag
        if x.tag_name == "var"
          var_name = x.attributes.keys.join(' ')
          append_to_io "#{var_name}.toString()"
          return
        end

        # =============================================================================
        # Attribute Options:
        # =============================================================================

        options = Collection_Options.new(x)

        if x.tag_name == "object"
          coll_name = options.name

          case options.vars.size
          when 2
            key_name, var_name = options.vars
          when 1
            key_name = "#{coll_name}_k"
            var_name = options.vars.last
          else
            options.invalid!
          end # case

          print "for (let #{key_name} in #{coll_name}) {\n"
          indent {
            print "let #{var_name} = #{coll_name}[#{key_name}];\n"
            x.children.each { |y| print_x(y) }
          }
          print "}\n"
          return
        end # if x.tag_name == "object"

        if x.tag_name == "negative"
          case options.vars.size
          when 0, 1
            print_block "if (#{options.name} < 0)" do
              if options.vars.size > 0
                let(options.vars.first, "#{options.name}")
              end
              print_children(x)
            end
          else
            options.invalid!
          end
          return
        end # if negative

        if x.tag_name == "zero"
          case options.vars.size
          when 0, 1
            print_block "if (#{options.name} === 0)" do
              if options.vars.size > 0
                let(options.vars.first, "#{options.name}")
              end
              print_children(x)
            end
          else
            options.invalid!
          end
          return
        end # if zero

        if x.tag_name == "positive"
          case options.vars.size
          when 0,1
            print_block "if (#{options.name} > 0)" do
              if options.vars.size > 0
                let(options.vars.first, "#{options.name}")
              end
              print_children(x)
            end
          else
            options.invalid!
          end
          return
        end # if positive

        if x.tag_name == "empty"
          case options.vars.size
          when 0,1
            print_block "if (#{options.name}.length === 0)" do
              if options.vars.size > 0
                let(options.vars.first, "#{options.name}")
              end
              print_children(x)
            end
          else
            options.invalid!
          end
          return
        end # if empty

        if x.tag_name == "not-empty"
          case options.vars.size
          when 0,1
            print_block "if (#{options.name}.length > 0)" do
              if options.vars.size > 0
                let(options.vars.first, "#{options.name}")
              end
              print_children(x)
            end
          else
            options.invalid!
          end
          return
        end # if empty

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
      end # case

    end # def print_x

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
      t.attributes({"href"=>"/UPCASE"})
      t.tag_text "#{t.tag_text} done"
      return t
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
puts js_template.to_js
File.write(
  "tmp/a.js",
  <<-JS
    #{js_template.to_js}
    {
      let data = {
        persons : [{name: "Phil", addresses: [{location: "Mongo City", planet: "Main Mongo"}, {location: "Star City", planet: "Earth"}]}],
        minus_3: -3,
        positive: 5,
        negative: -5,
        zero: 0,
        empty_array: [],
        };
      let s = template(data);
      console.log(data);
      console.log(s);
    }
  JS
)
Process.exec("node", "tmp/a.js".split)

