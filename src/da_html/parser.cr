
require "xml"

{% `mkdir -p tmp` %}
{% `rm -f tmp/da_html.tmp.*` %}
{% `touch tmp/da_html.tmp.tags` %}
{% `touch tmp/da_html.tmp.attrs` %}


module DA_HTML

  SAFE_TAG_A_ATTR_REL = "nofollow noopener noreferrer"

  struct Attr
    getter tag_name : String
    getter name : String
    getter content : String
    def initialize(@tag_name, @name, @content)
    end # === def initialize
  end # === class Node

  # === It's meant to be used within a Struct.
  module Parser

    getter doc = Doc.new

    @origin : String
    def initialize(raw : String)
      @origin = raw.strip
      raise Exception.new("Empty html") if @origin.empty?
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
        doc.instruct "doctype!", node.to_s

      when raw.cdata?
        content = (raw.content || "").strip
        raise Invalid_Text.new(raw) if !content.empty?

      when raw.text?
        text = allow("text!", raw)
        case text
        when String
          :done
        when XML::Node
          text = text.content
        when Symbol
          case text
          when :done
            return :done
          else
            raise Invalid_Text.new(raw)
          end
        end

        if text && !text.strip.empty?
          doc.instruct "text", text
        end

      when raw.attribute?
        clean_attr!(raw) do |attr|
          doc.instruct "attr", attr.name, attr.content
        end

      when raw.element?
        node = allow(raw.name, raw)
        if node.is_a?(XML::Node)
          doc.instruct "open-tag", node.name
          node.attributes.each { |a| parse(a) }
          node.children.each { |c| parse(c) }
          doc.instruct "close-tag", node.name
        else
          raise Invalid_Tag.new(raw)
        end # === case

      else
        raise Invalid_Tag.new(raw)
      end # == case type
    end # === def parse

    def allow_html_tag(node : XML::Node, **attrs)
      parent! node, "html"
      allow_attrs(node, **attrs)
      node
    end # === def allow_html_tag

    def allow_head_tag(node : XML::Node, **attrs)
      raise Invalid_Tag.new(node) unless node.element?

      name = node.name
      case name
      when "head"
        allow_html_tag(node, **attrs)
      else
        parent! node, "head"
        allow_attrs(node, **attrs)
        node
      end

    end # === def allow_head_tag

    def allow_body_tag(node : XML::Node, **attrs)
      raise Invalid_Tag.new(node) unless node.element?

      name = node.name
      case name
      when "body"
        allow_html_tag(node, **attrs)
      else
        in_tree! node, "body"
        allow_attrs(node, **attrs)
        node
      end
    end # === def allow_body_tag

    def allow_document_tag(node : XML::Node, **attrs)
      case

      when node.type == XML::Type::DTD_NODE
        content = node.to_s
        if content != "<!DOCTYPE html>"
          raise Invalid_Doctype.new(node)
        end
        node.attributes.each { |a| raise Invalid_Attr.new(node, a) }
        return node

      when node.element? && node.name != "document"
        parent = node.parent
        if !parent || parent.name != "document"
          raise Exception.new("#{node.name.inspect} tag must be at the toplevel of document")
        end

      else
        case node.type
        when XML::Type::DTD_NODE
          raise Invalid_Doctype.new(node)
        when
          raise Invalid_Tag.new(node)
        end

      end # === case

      allow_attrs(node, **attrs)

      return node
    end # === def allow_document_tag

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

    def clean_attr!(x : XML::Node)
      name = x.name
      parent = x.parent
      case
      when name == "rel" && parent && parent.name == "a"
        target = extract_attr(parent, "target")
        if target
          str = IO::Memory.new
          content = x.content.strip
          (str << content << " ") if !content.empty?
          str << SAFE_TAG_A_ATTR_REL
          doc.instruct "attr", "rel", str.to_s
        end

      when name == "target" && parent && parent.name == "a"
        yield x
        rel    = extract_attr(parent, "rel")
        if !rel
          yield Attr.new("a", "rel", SAFE_TAG_A_ATTR_REL)
        end
      else
        yield x
      end
    end # === def clean_attr!

    private def extract_attr(x : XML::Node, name : String)
      x.attributes.each { |attr|
        parent = x.parent
        if parent && attr.name == name
          return Attr.new(parent.name, x.name, x.content)
        end
      }
      return nil
    end # === def extract_attr

  end # === module Parser

end # === module DA_HTML

