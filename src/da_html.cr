
require "myhtml"
require "da"

module DA_HTML

  extend self

  alias Node = Text | Tag | Comment
  alias Attribute_Value = Int32 | Int64 | String

  def text?(x : Myhtml::Node)
    x.tag_name == "-text"
  end

  def comment?(n : Myhtml::Node)
    n.tag_name == "_comment"
  end

  def to_tag(n : Myhtml::Node, index : Int32) : Node
    case n.tag_name
    when "_comment"
      return Comment.new(n, index: index)
    when "-text"
      return Text.new(n, index: index)
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
      t.children.push DA_HTML.to_tag(y, index: i)
    }
    t
  end # def

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

end # === module DA_HTML

require "./da_html/Comment"
require "./da_html/Tag"
require "./da_html/Text"
require "./da_html/Document"
require "./da_html/Tag_Options"
require "./da_html/To_HTML"
require "./da_html/To_Javascript"
require "./da_html/Each_Node"
require "./da_html/Walk"

