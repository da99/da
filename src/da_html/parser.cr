
require "xml"

{% `mkdir -p tmp` %}
{% `rm -f tmp/da_html.tmp.*` %}
{% `touch tmp/da_html.tmp.tags` %}
{% `touch tmp/da_html.tmp.attrs` %}

module DA_HTML

  module Parser

    @origin : String = ""
    @root   : XML::Node

    getter file_dir : String
    getter io       : IO::Memory = IO::Memory.new

    def initialize(@root, @file_dir)
    end # === def initialize

    def initialize(@root, @io, @file_dir)
    end # === def initialize

    def initialize(file : String, @file_dir)
      @origin = DA_HTML.file_read!(@file_dir, file)
      @root   = XML.parse_html(@origin, XML::HTMLParserOptions::NOBLANKS | XML::HTMLParserOptions::PEDANTIC)
    end # === def initialize

    macro def_tags(*args, &blok)
      {% for name in args %}
        def_tag({{name}}) {{blok}}
      {% end %}
    end # === macro def_tags

    macro def_tag(name, &blok)
      {% `bash -c  "echo #{name.id} >> tmp/da_html.tmp.tags"` %}
        {% if blok %}
          def {{name.id}}({{blok.args.join(", ").id}} : XML::Node)
            {{blok.body}}
          end
        {% else %}
          def {{name.id}}(node : XML::Node)
            node
          end
        {% end %}
    end # === macro def_tag

    macro def_attr(tag_name, name, &blok)
      {% `bash -c  "echo #{tag_name.id} #{name.id} >> tmp/da_html.tmp.attrs"` %}
      {% if blok %}
        def {{tag_name.id}}_{{name.id}}({{blok.args.join(" : XML::Node, ").id}} : XML::Node)
          {{blok.body}}
        end
      {% else %}
        def {{tag_name.id}}_{{name.id}}(node : XML::Node, attr : XML::Node)
          attr.content = DA_HTML_ESCAPE.escape(attr.content)
          attr
        end
      {% end %}
    end # === macro attr

    macro finish_def_html!
      def render_element_node(node : XML::Node)
        name = node.name
        case name
          {% for x in system("cat tmp/da_html.tmp.tags").split("\n").reject { |x| x.empty? } %}
          when "{{x.id}}"
            {{x.id}}(node)
          {% end %}
        else
          raise Exception.new("Element not allowed: #{node.name.inspect}")
        end # === node.name
      end # === def render_element_node

      def render_element_attribute(node : XML::Node, attr : XML::Node)
        tag_name = node.name
        name     = attr.name
        {% if !`bash -c "cat tmp/da_html.tmp.attrs"`.strip.empty? %}
          case
            {% for x in system("cat tmp/da_html.tmp.attrs").split("\n").reject { |x| x.empty? } %}
            {% tag_name = x.split.first %}
            {% name     = x.split.last %}
            when tag_name == "{{tag_name.id}}" && name == "{{name.id}}"
              return {{tag_name.id}}_{{name.id}}(node, attr)
            {% end %}
          end # === node.name
        {% end %}
        raise Exception.new("Attribute not allowed: #{node.name.inspect} #{attr.name.inspect}")
      end
      {% `bash -c "rm -f tmp/da_html.tmp.attrs"` %}
    end # === macro render(node)

    def to_html
      @root.children.each { |node|
        self.class.new(@io, node).to_html
      }
      @io.to_s
    end # === def run

    getter last_was_text : Bool = false
    def last_was_text?
      @last_was_text
    end # === def last_was_text?

    def to_html
      node = @root
      last_was_text = false

      case node.type
      when XML::Type::DTD_NODE
        io << node.to_s

      when XML::Type::ELEMENT_NODE
        node = render_element_node(node)
        return if !node.is_a?(XML::Node)

        io << "\n"
        io.spaces
        attrs = node.attributes
        if attrs.empty?
          io << "<#{node.name}>"
        else
          io << "<#{node.name}"
          attrs.each { |a|
            new_a = render_element_attribute(node, a)
            if new_a.is_a?(XML::Node)
              io << " " << new_a.name << "=" << new_a.content.inspect
            end
          }
          io << ">"
        end
        io.indent
        node.children.each { |x|
          p = self.class.new(x, io, file_dir)
          p.to_html
          if node.children.size == 1
            last_was_text = p.last_was_text?
          end
        }

        if last_was_text || node.children.empty?
          io.de_indent
          io << "</#{node.name}>"
        else
          io << "\n"
          io.de_indent
          io.spaces
          io << "</#{node.name}>"
        end

      when XML::Type::ATTRIBUTE_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::TEXT_NODE
        new_txt = node.to_s.strip
        io << new_txt unless new_txt.empty?
        @last_was_text = true

      when XML::Type::CDATA_SECTION_NODE
        content = node.content.strip
        return if content.empty?
        raise Exception.new("Needs to be implemented: #{node.type.inspect} #{node.content.inspect}")

      when XML::Type::ENTITY_REF_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::ENTITY_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::PI_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::COMMENT_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::DOCUMENT_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::DOCUMENT_TYPE_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::DOCUMENT_FRAG_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::NOTATION_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::HTML_DOCUMENT_NODE
        # top most root element of a doc.
        node.children.each { |x|
          self.class.new(x, io, file_dir).to_html
        }

      when XML::Type::DTD_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::ELEMENT_DECL
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::ATTRIBUTE_DECL
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::ENTITY_DECL
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::NAMESPACE_DECL
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::XINCLUDE_START
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::XINCLUDE_END
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      when XML::Type::DOCB_DOCUMENT_NODE
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      else
        raise Exception.new("Needs to be implemented: #{node.type.inspect}")

      end # === case node.type

      io.to_s
    end # === def to_html

  end # === module Parser

end # === module DA_HTML

module IO

  class Memory

    @indent : Int32 = 0
    def indent
      @indent += 1
    end

    def spaces
      @indent.times do |i|
        self << "  "
      end
    end

    def de_indent
      @indent -= 1
    end

  end # === class Memory

end # === module IO
