
require "xml"

{% `mkdir -p tmp` %}
{% `rm -f tmp/da_html.tmp.*` %}
{% `touch tmp/da_html.tmp.tags` %}
{% `touch tmp/da_html.tmp.attrs` %}


module DA_HTML

  # === It's meant to be used within a Struct.
  module Parser

    getter doc : DOC = [] of INSTRUCTION
    def initialize(raw : String)
      @origin = raw
      parse
    end # === def initialize

    def parse
      return @doc unless @doc.empty?
      root = XML.parse_html(@origin, XML::HTMLParserOptions::NONET | XML::HTMLParserOptions::NOBLANKS | XML::HTMLParserOptions::PEDANTIC | XML::HTMLParserOptions::NODEFDTD)
      if @origin.index("<html")
        root.children.each { |x| parse(x) }
      else
        query(root, "html > body").children.each { |x| parse(x) }
      end
      @doc
    end # === def parse

    def parse(raw : XML::Node)
      case
      when raw.type == XML::Type::DTD_NODE
        node = allow("doctype!", raw)
        raise Invalid_Tag.new(raw) if !node.is_a?(XML::Node)
        doc << { "doctype!", node.to_s }

      when raw.cdata?
        content = (raw.content || "").strip
        raise Invalid_Text.new(raw) if !content.empty?

      when raw.text?
        text = raw.content
        if !text.strip.empty?
          doc << { "text", text }
        end

      when raw.attribute?
        doc << { "attr", raw.name, raw.content }

      when raw.element?
        node = allow(raw.name, raw)
        if node.is_a?(XML::Node)
          doc << { "open-tag", node.name }
          node.attributes.each { |a| parse(a) }
          node.children.each { |c| parse(c) }
          doc << { "close-tag", node.name }
        else
          raise Invalid_Tag.new(raw)
        end # === case

      else
        raise Invalid_Tag.new(raw)

      end # == case type

    end # === def parse

    def allow_head_tag(node : XML::Node, **attrs)
      raise Invalid_Tag.new(node) unless node.element?

      name = node.name
      case name
      when "head"
        parent! node, "html"
      else
        parent! node, "head"
      end
      allow_attrs(node, **attrs)

      node
    end # === def allow_tag

    def allow_body_tag(node : XML::Node, **attrs)
      raise Invalid_Tag.new(node) unless node.element?

      name = node.name
      case name
      when "body"
        parent! node, "html"
      else
        in_tree! node, "body"
      end
      allow_attrs(node, **attrs)

      node
    end # === def allow_body_tag

    def allow_tag(node : XML::Node, **attrs)
      case

      when node.type == XML::Type::DTD_NODE
        content = node.to_s
        if content != "<!DOCTYPE html>"
          raise Invalid_Doctype.new(node)
        end
        return node

      when node.element? && node.name == "html"
        parent = node.parent
        if !parent || parent.name != "document"
          raise Exception.new("\"html\" tag must be at the toplevel of document")
        end

      when node.element?
        parent! node, "html"

      else
        raise Invalid_Tag.new(node)

      end # === case

      allow_attrs(node, **attrs)

      return node
    end # === def allow_tag

    def allow_attrs(node : XML::Node, **names)
      node.attributes.each { |a|
        next if names[a.name]? && a.content =~ /^(#{names[a.name]})$/
        raise Invalid_Attr.new(node, a)
      }
      return node
    end # === def allow_attrs

    def parent!(node : XML::Node, name)
      target = node.parent
      return node if target && target.name == name
      raise Exception.new("#{node.name} must be inside a #{name.inspect}")
    end

    def in_tree!(node : XML::Node, name)
      target = node.parent
      while target
        return node if target.name == name
        target = target.parent
      end
      raise Exception.new("#{node.name} must be inside a #{name.inspect}")
    end

    def query(root : XML::Node, raw : String)
      pieces = raw.strip.split(/\s*\>\s*/)
      current = root

      while !pieces.empty? && current
        next_current = nil
        current.children.find { |x|
          if x.element? && x.name == pieces.first?
            next_current = x
            pieces.shift
          end
        }
        current = next_current
      end

      if !current
        raise Exception.new("Not found: #{raw.inspect}")
      end
      current
    end # === def query

  end # === module Parser

end # === module DA_HTML

