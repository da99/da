
require "xml"
{% `mkdir -p tmp` %}
{% `rm -f tmp/da_html.tmp.tags` %}
{% `touch tmp/da_html.tmp.tags` %}
module DA_HTML

  module Parser

    macro included
      def render_element_node(node : XML::Node)
        render_element_node!
      end # === def render_element_node
    end # === macro included

    @origin : String
    @root : XML::Node
    getter io : IO::Memory = IO::Memory.new

    def initialize(@root)
      @origin = ""
    end # === def initialize

    def initialize(@io, @root)
      @origin = ""
    end # === def initialize

    def initialize(file : String)
      @origin = File.read(file)
      @root = XML.parse_html(@origin, XML::HTMLParserOptions::NOBLANKS | XML::HTMLParserOptions::PEDANTIC)
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
      def {{tag_name.id}}_{{name.id}}({{blok.args.join(", ").id}} : NODE)
        {% if blok %}
          {{blok.body}}
        {% else %}
          node
        {% end %}
      end
    end # === macro attr

    macro render_element_node!
      name = node.name
      {% begin %}
        case name
          {% for x in system("cat tmp/da_html.tmp.tags").split("\n").reject { |x| x.empty? } %}
          when "{{x.id}}"
            {{x.id}}(node)
          {% end %}
        else
          raise Exception.new("Element not allowed: #{node.name.inspect}")
        end # === node.name
      {% end %}
      {% `bash -c "rm -f tmp/da_html.tmp.*"` %}
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
        io << "<#{node.name}>"
        io.indent
        node.children.each { |x|
          p = self.class.new(io, x)
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
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::TEXT_NODE
        new_txt = node.to_s.strip
        io << new_txt unless new_txt.empty?
        @last_was_text = true

      when XML::Type::CDATA_SECTION_NODE
        content = node.content.strip
        return if content.empty?
        raise Exception.new("Not ready: #{node.type.inspect} #{node.content.inspect}")

      when XML::Type::ENTITY_REF_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::ENTITY_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::PI_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::COMMENT_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::DOCUMENT_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::DOCUMENT_TYPE_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::DOCUMENT_FRAG_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::NOTATION_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::HTML_DOCUMENT_NODE
        # top most root element of a doc.
        node.children.each { |x|
          self.class.new(@io, x).to_html
        }


      when XML::Type::DTD_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::ELEMENT_DECL
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::ATTRIBUTE_DECL
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::ENTITY_DECL
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::NAMESPACE_DECL
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::XINCLUDE_START
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::XINCLUDE_END
        raise Exception.new("Not ready: #{node.type.inspect}")

      when XML::Type::DOCB_DOCUMENT_NODE
        raise Exception.new("Not ready: #{node.type.inspect}")

      else
        raise Exception.new("Not ready: #{node.type.inspect}")

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
