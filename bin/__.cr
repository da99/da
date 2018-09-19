
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

  def comment?(n : Myhtml::Node)
    n.tag_name == "_comment"
  end

  def to_tag(n : Myhtml::Node, parent : Tag?, index : Int32) : Node
    if text?(n) || comment?(n)
      return Text.new(n, parent: parent, index: index)
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
    getter index    = 0
    getter parent   : Tag? = nil
    @is_comment = false

    def initialize(n : Myhtml::Node, @parent, @index)
      @is_comment = n.tag_name == "_comment"
      @tag_text = n.tag_text
    end # === def

    def initialize(@tag_text, @parent, @index, @is_comment)
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

    def comment?
      @is_comment
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
      children.push Text.new(s, parent: self, index: children.size, is_comment: false)
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

    def comment?
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

  class Nodes

    def self.walk(t)
      yield t
      if t.is_a?(Tag)
        t.children.each { |c|
          walk(c)
        }
      end
    end # === def

    getter raw  : String
    getter nodes = [] of Node
    include Enumerable(DA_HTML::Tag | DA_HTML::Text)

    def initialize(raw : String)
      @raw = raw.gsub(/\<=([\ a-zA-Z0-9\.\_\-]+)\>/) { |x, y|
        "<var #{y[1]}></var>"
      }
      Myhtml::Parser.new(@raw).body!.children.each_with_index { |node, i|
        nodes.push DA_HTML.to_tag(node, parent: nil, index: i)
      }
    end # === def

    def each
      nodes.each { |x| yield x }
    end

    def map_walk!(&blok : Node -> Node | Nil)
      new_nodes = [] of Node
      nodes.each { |t|
        result = t.map_walk! { |t2| blok.call(t2) }
        case
        when result.is_a?(Tag) || result.is_a?(Text)
          new_nodes.push result
        when result == :remove
          nil
        end
      }
      @nodes = new_nodes
    end

  end # === class Nodes

  module Cleaner
    def clean(x) : Tag | Symbol
      raise Exception.new("Not implemented: #{self.to_s}.clean")
    end
  end # === struct Cleaner

  struct Collection_Options

    COLLECTION_PATTERN = /^([a-zA-Z\.\_\-0-9]+)\ +:\ +(\[(\ *[a-z\_0-9]+\ *)?\]\ +.+)$/
    AS_PATTERN         = /^([a-zA-Z\.\_\-0-9]+) as\ +([a-z0-9\_\,\ ]+)(:\ +(.+))?$/
    getter name     : String  = ""
    getter as_name  : String? = nil
    getter cr_type  : String? = nil
    getter key_name : String? = nil
    getter origin   : Tag

    def initialize(@origin)
      str = @origin.attributes["data-cr"].not_nil!.to_s
      is_valid = str.match(COLLECTION_PATTERN)

      if is_valid
        is_valid = is_valid.to_a.map { |x| (x.nil?) ? x : x.strip }
        @name    = is_valid[1].not_nil!
        @as_name = is_valid[3]?
        @cr_type = is_valid[2].not_nil!.sub("[#{as_name}]", "[]")
        return
      end

      is_valid = str.match(AS_PATTERN)

      if is_valid
        is_valid = is_valid.to_a.map { |x| (x.nil?) ? x : x.strip }

        @name    = is_valid[1].not_nil!
        pieces   = is_valid[2].not_nil!.split(/\ *,\ */).compact.map(&.strip)
        if is_valid[4]?
          @cr_type = is_valid[4]
        end

        case pieces.size
        when 2
          @key_name = pieces.first
          @as_name = pieces.last
        when 1
          @as_name = pieces.last
        else
          raise Exception.new("Invalid option: <#{origin.tag_name} #{str.inspect}")
        end
        return
      end # if

      raise Exception.new("Invalid option: <#{origin.tag_name} #{str.inspect}")
    end # def

    def raw
      "<#{origin.tag_name} #{origin.attributes.map { |k, v| "#{k}=#{v.inspect}" }.join ' '}>"
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
      raise Exception.new("#{m}: <#{origin.tag_name} #{origin.attributes.inspect}> ")
    end # === def

  end # === struct Collection_Options

  struct JS_Template

    getter nodes  : Nodes
    getter js_io  : IO::Memory = IO::Memory.new
    getter cr_io  : IO::Memory = IO::Memory.new
    getter pieces : Deque(String) = Deque(String).new
    getter levels : Deque(Int32) = Deque(Int32).new

    def initialize(x : String)
      @nodes = Nodes.new(x)
    end # def

    def initialize(@nodes)
    end # === def

    def javascript
      convert
      @js_io.to_s
    end

    def crystal
      convert
      @cr_io.to_s
    end

    def to_crystal(o : Collection_Options)
      o.invalid!("Missing Crystal Type") if !o.cr_type?
      meth_name = "type_check"
      s = <<-Crystal

        def #{meth_name}(#{o.as_name || "x"} : #{o.cr_type!})
          #{o.as_name || "x"}
        end

        def #{meth_name}(#{o.as_name || "x"} : T) forall T
          {% raise "got \#{T}, expected #{o.cr_type}: " + #{o.raw.inspect} %}
        end
        #{meth_name}(#{o.name})
        # (->(#{o.as_name || "x"} : #{o.cr_type!}) { #{o.as_name || "x"} }).call(#{o.name})
      Crystal
      cr_io << s
      s
    end

    def append_to_js(x : String)
      js_io << spaces << "io += " << x << ";\n"
      js_io
    end # === def

    def indent
      levels.push 1
      yield
      levels.pop
    end # === def

    def spaces
      "  " * levels.size
    end # === def

    def var_name(x : String)
      x.gsub(/[^a-zA-Z0-9\-]/, "_")
    end

    def let(x : String, y : String)
      js_io << spaces << "let " << var_name(x) << " = " << y << ";\n"
      js_io
    end # === def

    def print_line(x : String)
      js_io << spaces << x << ";\n"
      js_io
    end # === def

    def print_children(x)
      x.children.each { |y|
        print(y)
      }
    end # === def

    def print_block(s : String)
      print "#{s} {\n"
      indent {
        yield
      }
      print "} // #{s}\n"
    end

    def print(x : String)
      js_io << spaces << x
      js_io
    end

    def print(x : Node)
      case x

      when DA_HTML::Text
        return if x.empty?
        append_to_js x.tag_text.inspect
        return

      when DA_HTML::Tag
        if x.tag_name == "var"
          var_name = x.attributes.keys.join(' ')
          append_to_js "#{var_name}.toString()"
          return
        end

        if x.tag_name == "crystal"
          txt = x.children.find { |y| y.comment? }.not_nil!.tag_text.not_nil!.strip
           cr_io << txt
          return
        end

        # =============================================================================
        # Attribute Options:
        # =============================================================================

        if x.tag_name == "object"
          options   = Collection_Options.new(x)
          coll_name = options.name
          var_name  = options.as_name.not_nil!

          key_name = if options.key_name?
                       options.key_name.not_nil!
                     else
                       "#{coll_name}_k"
                     end

          print_block("for (let #{key_name} in #{coll_name})") {
            let var_name, "#{coll_name}[#{key_name}]"
            print_children(x)
          }
          return
        end # if x.tag_name == "object"

        if x.tag_name == "negative"
          options = Collection_Options.new(x)
          to_crystal(options)
          print_block("if (#{options.name} < 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, "#{options.name}")
            end
            print_children(x)
          }
          return
        end # if negative

        if x.tag_name == "zero"
          options = Collection_Options.new(x)
          to_crystal(options)
          print_block("if (#{options.name} === 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if zero

        if x.tag_name == "positive"
          options = Collection_Options.new(x)
          to_crystal(options)
          print_block("if (#{options.name} > 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if positive

        if x.tag_name == "empty"
          options = Collection_Options.new(x)
          print_block("if (#{options.name}.length === 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if empty

        if x.tag_name == "not-empty"
          options = Collection_Options.new(x)
          print_block("if (#{options.name}.length > 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if empty

        if x.tag_name == "array"
          options = Collection_Options.new(x)
          coll     = options.name
          var_name = options.as_name.not_nil!
          length   = var_name(coll) + "_length"
          i        = var_name(coll) + "_i"
          let length, "#{coll}.length"
          print_block("for(let #{i} = 0; #{i} < #{length}; ++#{i})") {
            let var_name, "#{coll}[#{i}]"
            print_children(x)
          }
          return
        end # if x.tag_name == "array"

        append_to_js "<#{x.tag_name} #{x.attributes.map { |k, v| "#{k}=\"#{v}\"" }.join ' '}>".inspect
        indent {
          print_children(x)
        }
        append_to_js("</#{x.tag_name}>".inspect) if x.end_tag?
      end # case

    end # def print

    def convert
      return self if !js_io.empty? || !cr_io.empty?
      print_block("function template(data)") {
        indent {
          let "io", "\"\""
          nodes.each { |x| print(x) }
          print "return io;\n"
        }
      }
      self
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

nodes = DA_HTML::Nodes.new(html)
nodes.map_walk! { |n|
  Upcase_HREF.clean(
    Clean_First_Text.clean(
      n
    )
  )
}

js_template = DA_HTML::JS_Template.new(nodes)
# puts js_template.javascript
puts js_template.crystal
File.write("tmp/html.cr", js_template.crystal)
Process.exec("crystal", "build tmp/html.cr -o tmp/html.cr.run".split)
# File.write(
#   "tmp/a.js",
#   <<-JS
#     #{js_template.javascript}
#     {
#       let data = {
#         persons : [{name: "Phil", addresses: [{location: "Mongo City", planet: "Main Mongo"}, {location: "Star City", planet: "Earth"}]}],
#         minus_3: -3,
#         positive: 5,
#         negative: -5,
#         zero: 0,
#         empty_array: [],
#         };
#       let s = template(data);
#       // console.log(data);
#       console.log(s);
#     }
#   JS
# )
# Process.exec("node", "tmp/a.js".split)

