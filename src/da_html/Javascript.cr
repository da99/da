
module DA_HTML::Javascript

  extend self

  def template_tags(doc : Deque(Node))
    bag = Deque(Node).new
    doc.each { |n|
      if n.is_a?(Tag) && n.tag_name == "template"
        bag.push n
        next
      end

      if n.is_a?(Tag)
        bag.concat template_tags(n.children)
        next
      end

      next
    }
    bag
  end # === def

  def to_javascript(nodes : Deque(Node))
    io = IO::Memory.new
    template_tags(nodes).each { |n|
      to_javascript(io, n)
    }
    io.to_s
  end # def

  def to_javascript(io, node : Node)
    case node
    when Comment
      :ignore

    when Text
      io << "\nio += #{node.to_html.inspect};" unless node.empty?

    when Tag
      {% begin %}
        case node.tag_name

          {% for x in "each each-in var template positive negative zero empty not-empty".split %}
          when {{x}}
            {{x.gsub(/-/, "_").id}}_to_javascript(io, node)
          {% end %}

        else
          tag_to_javascript(io, node)

        end
      {% end %}
    end # case
    io
  end # def

  def template_to_javascript(io, tag : Tag)
    io << '\n' << %[
      function #{tag.attributes["id"]}(data) {
        let io = "";
    ].strip
    tag.children.each { |x| to_javascript(io, x) }
    io << "\nreturn io;"
    io << "\n} // function"
    io
  end # === def

  def tag_to_javascript(io, tag : Tag)
    io << %[\nio += #{DA_HTML.open_tag(tag).gsub('"', %[\\"]).inspect};]
    unless tag.void?
      tag.children.each { |x| to_javascript(io, x) }
      io << %[\nio += #{DA_HTML.close_tag(tag).inspect};]
    end
  end # === def

  def var_to_javascript(io, node)
    text = node.children.first
    case text
    when Text
      io << %[\nio += #{text.tag_text}.toString();]
      io
    else
      raise Exception.new("Expecting text for node: #{node.inspect}")
    end
  end # === def

  def each_to_javascript(io, node)
    coll, _as, var = node.attributes.keys
    io << '\n' << %[
      for (let #{i coll} = 0, #{length coll} = #{coll}.length; #{i coll} < #{length coll}; ++#{i coll}) {
        let #{var} = #{coll}[#{i coll}];
    ].strip

    node.children.each { |x| to_javascript(io, x) }

    io << "\n}"
    io
  end # def

  def each_in_to_javascript(io, node)
    o = Tag_Options.new(node)
    coll, key, var = o.name!, o.key!, o.value!

    io << '\n' << %[
     for (let #{i(coll)} = 0, #{keys(coll)} = Object.keys(#{coll}), #{length(coll)} = #{keys coll}.length; #{i coll} < #{length coll}; ++#{i(coll)}) {
       let #{key} = #{keys coll}[#{i coll}];
       let #{var} = #{coll}[#{key}];
    ].strip
    node.children.each { |x| to_javascript(io, x) }
    io << "\n}"
    io
  end # === def

  def positive_to_javascript(io, node)
    var = node.attributes.keys.first
    js_block(io, "if (#{var} === 0)") {
      node.children.each { |x| to_javascript(io, x) }
    }
    io << " // if === 0"
    io
  end # def

  def negative_to_javascript(io, node)
    var = node.attributes.keys.first
    js_block(io, "if (#{var} < 0)") {
      node.children.each { |x| to_javascript(io, x) }
    }
    io << " // if < 0"
    io
  end # def

  def zero_to_javascript(io, node)
    var = node.attributes.keys.first
    js_block(io, "if (#{var} === 0)") {
      node.children.each { |x| to_javascript(io, x) }
    }
    io << " // if === 0"
    io
  end # def

  def empty_to_javascript(io, node)
    var = node.attributes.keys.first
    js_block(io, "if (#{var}.length === 0)") {
      node.children.each { |x| to_javascript(io, x) }
    }
    io << " // if length === 0"
    io
  end # def

  def not_empty_to_javascript(io, node)
    var = node.attributes.keys.first
    js_block(io, "if (#{var}.length > 0)") {
      node.children.each { |x| to_javascript(io, x) }
    }
    io << " // if length > 0"
    io
  end # def

  # =============================================================================
  # Helpers methods to print javascript:
  # =============================================================================

  def var_name(name : String)
    name.gsub(/[^a-z\_0-9]/, "_")
  end

  def i(name : String)
    "_#{var_name name}__i"
  end

  def keys(name : String)
    "_#{var_name name}__keys"
  end

  def length(name : String)
    "_#{var_name name}__length"
  end

  def var_name(x : String)
    x.gsub(/[^a-zA-Z0-9\-]/, "_")
  end

  def let(x : String, y : String)
    js_io << spaces << "let " << var_name(x) << " = " << y << ";\n"
    self
  end # === def

  def js_block(io, s : String)
    io << '\n' << "#{s} {"
      yield
    io << "\n}"
    io
  end

  struct Tag_Options

    def self.var_name!(x : String, msg : String)
      if !x[/^[a-zA-Z\.0-9]{1,35}$/]?
        raise Exception.new(msg)
      end
      x
    end

    AS_PATTERN = /^([a-zA-Z\.\_\-0-9]+)(\ +AS\ +([a-z0-9\_\,\ ]+))?$/i

    getter name  : String? = nil
    getter key   : String? = nil
    getter value : String? = nil
    getter raw : String

    def initialize(tag)
      @raw = tag.attributes.keys.join(' ')

      # Possible string values: "name as k, v"  "name"  "k, v" ...
      pieces = @raw.split(/ as /).map(&.strip).reject(&.empty?)
      case pieces.size
      when 0
        return
      when 1, 2
        @name = self.class.var_name!(pieces.shift, "Invalid collection name: #{raw}")
      else
        raise Exception.new("Too many \"as\" values: #{tag.tag_name} => #{raw}")
      end

      # Possible string values: "k,v" "k, v" "k , v" "v"
      pieces = pieces.join(' ').split(',').map(&.strip).reject(&.empty?)

      case pieces.size
      when 2
        @key = self.class.var_name!(pieces.shift, "Invalid key name: #{raw}")
      end
      @value = self.class.var_name!(pieces.pop, "Invalid value name: #{raw}")
    end # def

    {% for x in "name key value".split %}
      def {{x.id}}?
        !@{{x.id}}.nil?
      end

      def {{x.id}}!
        if @{{x.id}}.nil?
          raise Exception.new("Missing {{x.id}} name in: #{raw}")
        end
        @{{x.id}}.not_nil!
      end
    {% end %}

  end # === struct Tag_Options

end # === module DA_HTML::Javascript
