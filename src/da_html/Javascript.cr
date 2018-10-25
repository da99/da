
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

  def tag_options(tag)
    tag.attributes.keys.join(' ').split(/ as |,/).map(&.strip).reject(&.empty?)
  end # def

  def each_to_javascript(io, node)
    o = tag_options(node)
    if o[2]?
      coll, index, var = o[0], o[1], o[2]
    else
      coll, index, var = o[0], nil, o[1]?
    end

    js_block(io, %[for (let #{i coll} = 0, #{length coll} = #{coll}.length; #{i coll} < #{length coll}; ++#{i coll})]) {
      io << "\nlet #{index} = #{i coll};" if index
      io << "\nlet #{var} = #{coll}[#{i coll}];" if var

      node.children.each { |x| to_javascript(io, x) }
    }
    io
  end # def

  def each_in_to_javascript(io, node)
    o = tag_options(node)
    coll, key, var = o[0], o[1], o[2]

    js_block(io, %[for (let #{i(coll)} = 0, #{keys(coll)} = Object.keys(#{coll}), #{length(coll)} = #{keys coll}.length; #{i coll} < #{length coll}; ++#{i(coll)})]) {
      io << "\nlet #{key} = #{keys coll}[#{i coll}];" if key
      io << "\nlet #{var} = #{coll}[#{key}];" if var
      node.children.each { |x| to_javascript(io, x) }
    }
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

end # === module DA_HTML::Javascript
