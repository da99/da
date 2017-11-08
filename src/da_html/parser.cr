
require "xml"

{% `mkdir -p tmp` %}
{% `rm -f tmp/da_html.tmp.*` %}
{% `touch tmp/da_html.tmp.tags` %}
{% `touch tmp/da_html.tmp.attrs` %}

require "./parser/exception"
require "./parser/template"
require "./parser/class_methods"


module DA_HTML
  alias INSTRUCTION = Tuple(String, String) | Tuple(String, String, String)
  alias DOC = Array(INSTRUCTION)

  # === It's meant to be used within a Struct.
  module Parser

    extend Class_Methods

    macro included
      extend Class_Methods
    end # === macro included

    SEGMENT_ATTR_ID    = /([a-z0-9\_\-]{1,15})/
    SEGMENT_ATTR_CLASS = /[a-z0-9\ \_\-]{1,50}/
    SEGMENT_ATTR_HREF  = /[a-z0-9\ \_\-\/\.]{1,50}/

    getter file_dir : String
    getter io       : IO::Memory = IO::Memory.new
    getter doc      : DOC

    def initialize(@doc, @file_dir)
    end # === def initialize

    macro def_tags(*args, &blok)
      {% for name in args %}
        def_tag({{name}}) {{blok}}
      {% end %}
    end # === macro def_tags

    macro def_tag(name, &blok)
      {% `bash -c  "echo #{name.id} >> tmp/da_html.tmp.tags"` %}
      {% if blok %}
        def render_tag_{{name.id}}(*attrs, children)
          {{blok.body}}
        end
      {% else %}
        def render_tag_{{name.id}}(*attrs, children)
          render("{{name.id}}", *attrs, children)
        end
      {% end %}
    end # === macro def_tag

    macro def_attr(tag_name, name, pattern)
      {% pattern_name = "PATTERN_ATTR_#{tag_name.id.upcase.gsub(/[^0-9A-Z\_]/, "_")}_#{name.id.upcase.gsub(/[^A-Z0-9]/, "_")}".id %}
      {{pattern_name}} = /^(#{{{pattern}}})$/

      {% `bash -c  "echo #{tag_name.id} #{name.id} >> tmp/da_html.tmp.attrs"` %}
      def render_tag_{{tag_name.id}}_attr_{{name.id}}(content : String)
        case
        when content =~ {{pattern_name}}
          DA_HTML_ESCAPE.escape(attr.content)
        else
          raise Invalid_Attr_Value.new("{{tag_name.id}} {{name.id}}:  #{content.inspect}")
        end
      end
    end # === macro attr

    macro def_attr(tag_name, name, &blok)
      {% `bash -c  "echo #{tag_name.id} #{name.id} >> tmp/da_html.tmp.attrs"` %}
      {% if blok %}
        def render_{{tag_name.id}}_attr_{{name.id}}(
          content : String
        )
          {{blok.body}}
        end
      {% else %}
        def_attr({{tag_name}}, {{name}}, SEGMENT_ATTR_{{name.id.upcase.gsub(/[^A-Z0-9]/, "_")}})
      {% end %}
    end # === macro attr

    macro finish_def_html!
      def clean_node(node : DA_HTML::Parser::Tag)
        name = node.name
        {% if !`bash -c "cat tmp/da_html.tmp.tags 2>/dev/null || :"`.strip.empty? %}
          case name
            {% for x in system("bash -c \"cat tmp/da_html.tmp.tags\"").split("\n").reject { |x| x.empty? } %}
            when "{{x.id}}"
              return clean_tag_{{x.id}}(node)
            {% end %}
          end
        {% end %}
        return nil
      end # === def clean_node

      def clean_attr(node : DA_HTML::Parser::Tag, attr : DA_HTML::Parser::Tag)
        tag_name = node.name
        name     = attr.name
        {% if !`bash -c "cat tmp/da_html.tmp.attrs 2>/dev/null || :"`.strip.empty? %}
          case
            {% for x in system("cat tmp/da_html.tmp.attrs").split("\n").reject { |x| x.empty? } %}
            {% tag_name = x.split.first %}
            {% name     = x.split.last %}
            when tag_name == "{{tag_name.id}}" && name == "{{name.id}}"
              return clean_tag_{{tag_name.id}}_attr_{{name.id}}(node, attr)
            {% end %}
          end # === node.name
        {% end %}
        raise Invalid_Attr.new("#{node.name.inspect} #{attr.name.inspect}")
      end
      {% `bash -c "rm -f tmp/da_html.tmp.*"` %}
    end # === macro render(node)

    def run
      inspect! @doc
      raise Exception.new("not ready")
      self
    end # === def to_html

    def to_html
      run
      io.to_s
    end # === def to_html

    def render(node : DA_HTML::Parser::Tag)
      io << "<#{node.name}"

      attrs = node.attributes
      if attrs.is_a?(Array)
        attrs.each { |a|
          clean_a = clean_attr(node, a)
          pair = case clean_a
                 when XML::Node
                   {clean_a.name, clean_a.content}
                 when Tuple(String, String)
                   clean_a
                 else
                   raise Invalid_Attr.new("For tag #{node.name}: #{a.name}")
                 end

          io << " " << pair.first << "=" << (DA_HTML_ESCAPE.escape(pair.last) || "").inspect
        }
      end

      io << ">"

      childs = node.children
      if childs.is_a?(Array)
        childs.each { |x|
          p = self.class.new(x, io, file_dir)
          p.to_html
        }
      end

      io << "</#{node.name}>"
    end # === def render

  end # === module Parser

end # === module DA_HTML

