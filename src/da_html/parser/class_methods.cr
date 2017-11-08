
module DA_HTML

  module Parser

    module Class_Methods

      def parse(raw : String) : Array(INSTRUCTION)
        doc = [] of INSTRUCTION
        root = XML.parse_html(raw, XML::HTMLParserOptions::NOBLANKS | XML::HTMLParserOptions::PEDANTIC)
        root.children.each { |x|
          type = x.type
          case type
          when XML::Type::DTD_NODE
            new_x = parse_tag(:doctype!, x)
            raise Invalid_Tag.new(x) if !new_x.is_a?(XML::Node)
            doc << { "doctype!", new_x.to_s }

          when XML::Type::CDATA_SECTION_NODE
            content = (x.content || "").strip
            next if content.empty?
            raise Exception.new("CDATA node needs to be implemented: #{x.content.inspect}")

          when XML::Type::ELEMENT_NODE
            new_x = parse_tag(x.name, x)
            raise Invalid_Tag.new(x) if !new_x.is_a?(XML::Node)
            parse_node_into_doc(doc, new_x)

          else
            raise Exception.new("No implementation for: #{x.type}")
          end # == case type

        }
        doc
      end # === def parse

      def allow_tag(node : XML::Node)
        type = node.type
        case type
        when XML::Type::ELEMENT_NODE
          name = node.name
          case name
          when "html"
            parent = node.parent
            if !parent || parent.name != "document"
              raise Exception.new("\"html\" tag must be at the toplevel of document")
            end
            node
          when "head"
            Parser.in_tree! node, "html"
          when "title"
            Parser.in_tree! node, "head"
          when "input"
            Parser.in_tree! node, "form"
          else
            node
          end

        when XML::Type::DTD_NODE
          content = node.to_s
          if content != "<!DOCTYPE html>"
            raise Invalid_Doctype.new(node)
          end
          node

        else
          raise Exception.new("Unknown type: #{type.inspect}")

        end # === case
      end # === def allow_tag

      def allow_tag_with_attributes(node : XML::Node, *names)
        node.attributes.each { |a|
          next if names.includes?(a.name)
          raise Invalid_Attr.new(node, a)
        }
        node
      end # === def allow_tag_with_attributes

      def parse_node_into_doc(doc : DOC, node : XML::Node)
        doc << { "open-tag", node.name }
        node.attributes.each { |a|
          doc << { "attr", a.name, a.content }
        }

        node.children.each { |c|
          c_type = c.type
          case c_type
          when XML::Type::TEXT_NODE
            text = c.content
            if !text.strip.empty?
              doc << { "text", text }
            end
          when XML::Type::ELEMENT_NODE
            parse_node_into_doc(doc, c)
          else
            raise Exception.new("No parse_tag implementation for: #{c_type.inspect}")
          end
        }
        doc << { "close-tag", node.name }
      end # === def parse_tag

      def new_from_file(file, dir)
        source = DA_HTML.file_read!(dir, file)
        new(parse(source), dir)
      end # === def new_from_file

      def in_tree!(node : XML::Node, name)
        target = node.parent
        while target
          return target if target.name == name
          target = target.parent
        end
        raise Exception.new("#{node.name} must be inside a #{name.inspect}")
        node
      end

    end # === module Class_Methods

  end # === module Parser

end # === module DA_HTML
