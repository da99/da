
module DA_HTML

  class JS_Printer

    getter js_io = IO::Memory.new

    def initialize
    end # === def

    def <<(*args)
      args.each { |x| js_io << x }
      js_io
    end

    def to_s(io)
      js_io.to_s(io)
    end

    def html_printer
      To_HTML
    end

    def print_open_tag(tag : Tag)
      case tag.tag_name
      when "html", "head", "body"
        return tag
      when "script"
        self << "function #{tag.attributes["id"]} {\n  let io = \"\";\n  "
      else
        html_printer.to_html_open_tag(self, tag)
      end
      tag
    end # === def

    def print_close_tag(tag : Tag)
      case tag.tag_name
      when "html", "head"
        return tag
      when "script"
        self << "\n  return io;\n}\n"
      else
        html_printer.to_html_close_tag(self, tag)
      end
      tag
    end # === def

    def convert
      return self if !js_io.empty?
      print_block("function template(data)") {
        indent {
          let "io", "\"\""
          nodes.each { |x| print(x) }
          print "return io;\n"
        }
      }
      self
    end # === def

    def append_to_js(x : String)
      js_io << spaces << "io += " << x << ";\n"
      js_io
    end # === def

    def indent
      levels.push 1
      yield
      levels.pop
    end # === def

    def spaces
      "  " * levels.size
    end # === def

    def var_name(x : String)
      x.gsub(/[^a-zA-Z0-9\-]/, "_")
    end

    def let(x : String, y : String)
      js_io << spaces << "let " << var_name(x) << " = " << y << ";\n"
      js_io
    end # === def

    def print_line(x : String)
      js_io << spaces << x << ";\n"
      js_io
    end # === def

    def print_children(x)
      x.children.each { |y|
        print(y)
      }
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
      js_io
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


  end # === class JS_Printer

  module To_Javascript
    extend self

    def to_javascript(document)
      to_javascript(JS_Printer.new, document).to_s
    end # def

    def to_javascript(io, document)
      Walk.walk(io, document)
      io
    end # def

  end # === struct To_Javascript
end # === module DA_HTML
