
module DA_HTML

  extend self

  alias Node = Text | Tag
  alias Attribute_Value = Int32 | Int64 | String

  def html5_prepend
    <<-HTML5
    <!doctype html>
    <html lang="en">
    HTML5
  end

  def close_custom_tags(s : String)
    s
      .sub(/<html>/, html5_prepend)
      .gsub(/\<=([\ a-zA-Z0-9\.\_\-]+)\>/) { |x, y| "<var #{y[1]}></var>" }
      .gsub(/\<include\ +"?([^"\>]+)"?\>/) { |x, y| File.read(y[1]) }
      .gsub(/\<template\ +"?([^"\>]+)"?\>/) { |x, y| %[<template>#{y[1]}</template>] }
  end # === def

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

require "./da_html/Tag"
require "./da_html/Text"
require "./da_html/Document"
require "./da_html/Tag_Options"
require "./da_html/To_HTML"
require "./da_html/To_JS"

