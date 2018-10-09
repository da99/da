
module DA_HTML

  module To_Javascript

    extend self

    def to_javascript(document : Document)
      io = IO::Memory.new
      to_javascript(io, document.children)
      io.to_s
    end # def

    def to_javascript(io, nodes : Array(Node))
      nodes.each { |node|
        to_javascript(io, node)
      }
      io
    end # === def

    # NOTE: .to_javascript is to filter out
    # HTML that exists out of the <script> tag.
    # .to_javascript! is for tags inside <script> tag.
    # In other words, .to_javascript is to ignore tags,
    # .to_javascript! is to always render tags.
    def to_javascript(io, n : Node)
      case n
      when Tag
        if n.tag_name == "template"
          template_tag_to_javascript(io, n)
        else
          to_javascript(io, n.children)
        end
      end # case
      io
    end # === def

    def template_tag_to_javascript(io, n : Node)
      io << %[
        function #{n.attributes["id"]}(data) {
          let io = "";
      ]
      io = to_javascript!(io, n.children)
      io << %[ return io;\n} ]
      io
    end # === def

    def to_javascript!(io, nodes : Array(Node))
      nodes.each { |n|
        to_javascript!(io, n)
      }
      io
    end # === def

    def to_javascript!(io, node : Node)
      case node
      when Comment
        :ignore
      when Text
        io << %[ io += #{node.to_html.inspect};\n] unless node.empty?
      when Tag
        case node.tag_name
        when "each"
          each_to_javascript(io, node)
        when "each-in"
          each_in_to_javascript(io, node)
        when "var"
          var_to_javascript(io, node)
        else
          io << %[ io += #{To_HTML.to_html_open_tag(node).inspect};\n]
          node.children.each { |n|
            to_javascript!(io, n)
          }
          io << %[ io += #{To_HTML.to_html_close_tag(node).inspect};\n]
        end
      else
        raise Exception.new("Unknown tag for template javascript: #{node.inspect}")
      end

      io
    end # === def

    def var_to_javascript(io, node)
      name = node.tag_text
      io << %[io += #{name}.toString();\n]
      io
    end # === def

    def each_to_javascript(io, node)
      coll, _as, var = node.attributes.keys
      io << %[
        for (let #{i coll} = 0, #{length coll} = #{coll}.length; #{i coll} < #{length coll}; ++#{i coll}) {
          let #{var} = #{coll}[#{i coll}];
      ].lstrip
      to_javascript!(io, node.children)

      io << %[ }\n ]
      io
    end # def

    def var_name(name : String)
      name.gsub(/[^a-z\_0-9]/, "_")
    end

    def i(name : String)
      "_#{var_name name}__i"
    end

    def data(name : String)
      "data.#{name}"
    end

    def keys(name : String)
      "_#{var_name name}__keys"
    end

    def length(name : String)
      "_#{var_name name}__length"
    end

    def each_in_to_javascript(io, node)
      coll, _as, key, var = node.attributes.keys.join(' ').split(/\ |,/)
      io << %[
       for (let #{i(coll)} = 0, #{keys(coll)} = Object.keys(#{coll}), #{length(coll)} = #{keys coll}.length; #{i coll} < #{length coll}; ++#{i(coll)}) {
         let #{key} = #{keys coll}[#{i coll}];
         let #{var} = #{coll}[#{key}];
      ].lstrip
      to_javascript!(io, node.children)
      io << %[ }\n]
      io
    end # === def

    # =============================================================================
    # Instance:
    # =============================================================================


    def var_name(x : String)
      x.gsub(/[^a-zA-Z0-9\-]/, "_")
    end

    def let(x : String, y : String)
      js_io << spaces << "let " << var_name(x) << " = " << y << ";\n"
      self
    end # === def

    def print_line(x : String)
      js_io << spaces << x << ";\n"
      self
    end # === def

    def print_block(s : String)
      print "#{s} {\n"
      indent {
        yield
      }
      print "} // #{s}\n"
    end

    def print(x : Text | Comment)
      js_io << x.tag_text
      self
      # js_io << spaces << x
      # js_io
    end

    def _print(x : Node)
      case

      when x.is_a?(DA_HTML::Text)
        return if x.empty?
        append_to_js x.tag_text.inspect
        return

      when x.tag_name == "var"
          var_name = x.attributes.keys.join(' ')
          append_to_js "#{var_name}.toString()"
          return

      when x.tag_name == "negative"

          options = Tag_Options.new(x)
          to_crystal("negative", options)
          print_block("if (#{options.name} < 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, "#{options.name}")
            end
            print_children(x)
          }
          return

      when x.tag_name == "zero"

          options = Tag_Options.new(x)
          to_crystal("zero", options)
          print_block("if (#{options.name} === 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return

      when x.tag_name == "positive"

          options = Tag_Options.new(x)
          to_crystal("positive", options)
          print_block("if (#{options.name} > 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return

      when x.tag_name == "empty"
          options = Tag_Options.new(x)
          to_crystal("empty", options)
          print_block("if (#{options.name}.length === 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return

      when x.tag_name == "not-empty"
          options = Tag_Options.new(x)
          to_crystal("not-empty", options)
          print_block("if (#{options.name}.length > 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return

      when x.print_in_html?
        append_to_js "<#{x.tag_name} #{x.attributes.map { |k, v| "#{k}=\"#{v}\"" }.join ' '}>".inspect
        indent {
          print_children(x)
        }
        append_to_js("</#{x.tag_name}>".inspect) if x.end_tag?

      end # case

    end # def print


  end # === struct To_Javascript

end # === module DA_HTML
