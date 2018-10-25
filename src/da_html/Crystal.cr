
module DA_HTML::Crystal
  extend self

  def main_tags(nodes)
    tags = Deque(Tag).new
    nodes.each { |x|
      case x
      when Tag
        case x.tag_name
        when "crystal", "template"
          tags << x
        else
          tags.concat main_tags(x.children)
        end
      end
    }
    tags
  end # def

  def to_crystal(io, nodes)
    main_tags(nodes).each { |x|
      render(io, x)
    }
    io
  end # def

  def render(io, x : Text | Comment | Tag)
    case x
    when Tag
      {% begin %}
      case x.tag_name
      when "crystal"
        io << x.tag_text

      when "template"
        func = x.attributes["id"]
        io << "\ndef #{func}(data)"
        x.children.each { |c| render(io, c) }
        io << "\nend"
        io << "\n#{func}(data)"

        {% for x in "each each-in zero positive negative empty not-empty".split %}
          when {{x}}
            {{x.gsub(/-/, "_").id}}_to_crystal(io, x)
        {% end %}

      else
        if !HTML.known_tag?(x)
          raise Exception.new("Implementation needed to render unknown tag: #{x.inspect}")
        end
        x.children.each { |c| render(io, c) }
      end
      {% end %}
    end # case x
    io
  end # def

  def each_to_crystal(io, x : Tag)
    o = Javascript.tag_options(x)
    case
    when o[0]? && o[1]? && o[2]?
      coll, k, v = o[0], o[1], o[2]
      cr_block(io, %[#{coll}.each_with_index { |#{v}, #{k}|]) {
        x.children.each { |c| render(io, c) }
      }
    when o[0]? && o[1]?
      coll, v = o[0], o[1]
      cr_block(io, %[#{coll}.each { |#{v}| ]) {
        x.children.each { |c| render(io, c) }
      }
    else
      raise Exception.new("Invalid tag: #{x.inspect}")
    end
  end # def

  def each_in_to_crystal(io, x : Tag)
    o = Javascript.tag_options(x)
    case
    when o[0]? && o[1]? && o[2]?
      coll, k, v = o[0], o[1], o[2]
      cr_block(io, %[#{coll}.each { |#{k}, #{v}|]) {
        x.children.each { |c| render(io, c) }
      }
    else
      raise Exception.new("Invalid tag: #{x.inspect}")
    end
    io
  end # def

  def zero_to_crystal(io, x : Tag)
    o = Javascript.tag_options(x)
    case
    when o[0]? # <zero data.key>
      coll, v = o[0]
      cr_if(io, %[#{o[0]} == 0]) {
        x.children.each { |c| render(io, c) }
      }
    else
      raise Exception.new("Invalid tag: #{x.inspect}")
    end
    io
  end # def

  def positive_to_crystal(io, x : Tag)
    o = Javascript.tag_options(x)
    case
    when o[0]? # <positive data.key>
      coll, v = o[0]
      cr_if(io, %[#{o[0]} > 0]) {
        x.children.each { |c| render(io, c) }
      }
    else
      raise Exception.new("Invalid tag: #{x.inspect}")
    end
    io
  end # def

  def negative_to_crystal(io, x : Tag)
    o = Javascript.tag_options(x)
    case
    when o[0]? # <negative data.key>
      coll, v = o[0]
      cr_if(io, %[#{o[0]} < 0]) {
        x.children.each { |c| render(io, c) }
      }
    else
      raise Exception.new("Invalid tag: #{x.inspect}")
    end
    io
  end # def

  def empty_to_crystal(io, x : Tag)
    o = Javascript.tag_options(x)
    case
    when o[0]? # <empty data.key>
      coll, v = o[0]
      cr_if(io, %[#{o[0]}.empty?]) {
        x.children.each { |c| render(io, c) }
      }
    else
      raise Exception.new("Invalid tag: #{x.inspect}")
    end
    io
  end # def

  def not_empty_to_crystal(io, x : Tag)
    o = Javascript.tag_options(x)
    case
    when o[0]? # <not_empty data.key>
      coll, v = o[0]
      cr_if(io, %[!#{o[0]}.empty?]) {
        x.children.each { |c| render(io, c) }
      }
    else
      raise Exception.new("Invalid tag: #{x.inspect}")
    end
    io
  end # def



  def cr_block(io, x : String)
    io << '\n' << x
    io << " {" unless x.strip[/\|$/]?
    yield
    io << "\n}"
  end # def

  def cr_if(io, x : String)
    io << "\nif " << x
    yield
    io << "\nend"
  end # def

end # === module DA_HTML::Crystal
