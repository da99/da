
module DA_HTML
  struct To_JS

    getter document : Document
    getter js_io   : IO::Memory    = IO::Memory.new
    getter cr_io   : IO::Memory    = IO::Memory.new
    getter levels  : Deque(Int32)  = Deque(Int32).new

    def initialize(@document)
    end # def

    def convert
      return self if !js_io.empty? || !cr_io.empty?
      print_block("function template(data)") {
        indent {
          let "io", "\"\""
          nodes.each { |x| print(x) }
          print "return io;\n"
        }
      }
      self
    end # === def

    def to_crystal(tag_name : String, o : Tag_Options)
      as_name   = o.as_name || "x"
      s = <<-Crystal

        js_#{tag_name.gsub(/[^a-z0-9\_]/, '_')}(#{o.name})
      Crystal
      cr_io << s
      s
    end # def to_crystal

    def to_crystal
      document.cr_io.to_s
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

    def print(x : String)
      js_io << spaces << x
      js_io
    end

    def print(x : Node)
      case x

      when DA_HTML::Text
        return if x.empty?
        append_to_js x.tag_text.inspect
        return

      when DA_HTML::Tag
        if x.tag_name == "var"
          var_name = x.attributes.keys.join(' ')
          append_to_js "#{var_name}.toString()"
          return
        end

        if x.tag_name == "crystal"

          if cr_io.empty?
            @cr_io << <<-Crystal

              def js_negative(x : Int32 | Int64)
                x
              end
              def js_positive(x : Int32 | Int64)
                x
              end
              def js_zero(x : Int32 | Int64)
                x
              end
              def js_empty(x : Array(T)) forall T
                x
              end
              def js_not_empty(x : Array(T)) forall T
                x
              end
              def js_each(x : Array(T)) forall T
                x
              end
              def js_each(x : Hash(K,V)) forall K,V
                x
              end

            Crystal
          end

          txt = x.children.find { |y| y.comment? }.not_nil!.tag_text.not_nil!.strip
           cr_io << txt
          return
        end

        # =============================================================================
        # Attribute Options:
        # =============================================================================

        if x.tag_name == "object"
          options   = Tag_Options.new(x)
          coll_name = options.name
          var_name  = options.as_name.not_nil!

          key_name = if options.key_name?
                       options.key_name.not_nil!
                     else
                       "#{coll_name}_k"
                     end

          print_block("for (let #{key_name} in #{coll_name})") {
            let var_name, "#{coll_name}[#{key_name}]"
            print_children(x)
          }
          return
        end # if x.tag_name == "object"

        if x.tag_name == "negative"
          options = Tag_Options.new(x)
          to_crystal("negative", options)
          print_block("if (#{options.name} < 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, "#{options.name}")
            end
            print_children(x)
          }
          return
        end # if negative

        if x.tag_name == "zero"
          options = Tag_Options.new(x)
          to_crystal("zero", options)
          print_block("if (#{options.name} === 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if zero

        if x.tag_name == "positive"
          options = Tag_Options.new(x)
          to_crystal("positive", options)
          print_block("if (#{options.name} > 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if positive

        if x.tag_name == "empty"
          options = Tag_Options.new(x)
          to_crystal("empty", options)
          print_block("if (#{options.name}.length === 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if empty

        if x.tag_name == "not-empty"
          options = Tag_Options.new(x)
          to_crystal("not-empty", options)
          print_block("if (#{options.name}.length > 0)") {
            if options.as_name?
              let(options.as_name.not_nil!, options.name)
            end
            print_children(x)
          }
          return
        end # if empty

        if x.tag_name == "array"
          options = Tag_Options.new(x)
          coll     = options.name
          var_name = options.as_name.not_nil!
          length   = var_name(coll) + "_length"
          i        = var_name(coll) + "_i"
          let length, "#{coll}.length"
          print_block("for(let #{i} = 0; #{i} < #{length}; ++#{i})") {
            let var_name, "#{coll}[#{i}]"
            print_children(x)
          }
          return
        end # if x.tag_name == "array"

        append_to_js "<#{x.tag_name} #{x.attributes.map { |k, v| "#{k}=\"#{v}\"" }.join ' '}>".inspect
        indent {
          print_children(x)
        }
        append_to_js("</#{x.tag_name}>".inspect) if x.end_tag?
      end # case

    end # def print

  end # === struct To_JS
end # === module DA_HTML
