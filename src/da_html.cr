
require "myhtml"
require "da_html_escape"
require "da"

module DA
  def strip_each_line(s : String)
    s.strip.lines.map { |x| x.strip }.join('\n')
  end # def
end # === module DA

module DA_HTML

  extend self

  alias Node = Text | Comment | Tag
  alias Attribute_Value = Int32 | Int64 | String

  def find_tag_name(node, tag_name : String)
    tag_name.split(/\ *>\ */).reduce(node) { |n, t|
      result = _find_tag_name(n, t)

      case result
      when Tag
        :ignore
      else
        return nil
      end
      result
    }
  end

  def _find_tag_name(node, tag_name : String)
    result = node.children.find { |n| n.tag_name == tag_name }
    result
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

  def to_tag(n : Myhtml::Node) : Node
    case n.tag_name
    when "_comment"
      Comment.new(n)
    when "-text"
      Text.new(n)
    else
      Tag.new(n)
    end
  end # def

  def to_tags(raw : String)
    doc    = Deque(Node).new
    html   = DA.until_done(raw) { |x| DA_HTML.cleanup(x) }
    parser = Myhtml::Parser.new(html)

    doc.push DA_HTML.to_tag(parser.root!)

    doc
  end # === def

  def html5_prepend
    <<-HTML5
      <!doctype html>
      <html lang="en">
    HTML5
  end

  def cleanup(s : String)
    s
      .sub(/<html>/, html5_prepend)
      .gsub(/\<=([\ a-zA-Z0-9\.\_]+)\>/) { |x, y| "<var>#{y[1]}</var>" }
      .gsub(/\<include\ +"?([^"\>]+)"?\>/) { |x, y| File.read(y[1]) }
      .gsub(/\<template\ +"?([^"\>]+)"?\>/) { |x, y| %[<template>#{File.read y[1]}</template>] }
  end # === def

  def body(doc : Deque(Node))
    body = DA_HTML.find_tag_name(doc, "html > body")
    case body
    when Tag
      return body
    else
      raise Exception.new("Tag not found: body")
    end
  end # === def

  def to_javascript(nodes : Deque(Node))
    Javascript.to_javascript(nodes)
  end

end # === module DA_HTML

require "./da_html/Comment"
require "./da_html/Tag"
require "./da_html/Text"
require "./da_html/JS_String"
require "./da_html/Fragment"
require "./da_html/Tag_Options"
require "./da_html/To_HTML"
require "./da_html/Javascript"
require "./da_html/Each_Node"

