
module DA_HTML

  module Printer

    module Class_Methods

      def new_from_da_html(raw : String, *args)
        doc = DA_HTML::Format.to_doc(raw)
        new(doc, *args)
      end # === def new_from_da_html

    end # === module Class_Methods

    getter file_dir : String
    getter io       : IO_HTML = IO_HTML.new
    getter doc      : Doc

    macro included
      extend Class_Methods
    end # === macro included

    def initialize(raw : String, @file_dir)
      {% begin %}
        @doc = {{@type}}::Parser.new(raw).parse
      {% end %}
    end # === def initialize

    def initialize(@doc : Doc, @file_dir)
    end # === def initialize

    def capture(new_io : IO_HTML)
      old_io = @io
      @io = new_io
      yield @io
      @io = old_io
      new_io
    end # === def capture

    def to_html(i : Instruction)
      action = i.first
      case action
      when "doctype!"
        io.raw! i.last

      when "open-tag"
        if doc.current? && doc.current.attr?
          io.open_attrs(i.last)
        else
          io.open_tag(i.last)
        end

      when "attr"
        io.write_attr(i[1], i.last)
        if doc.current? && !doc.current.attr?
          io.close_attrs
        end

      when "text"
        io.write_text(i.last)

      when "close-tag"
        io.close_tag(i.last)

      else
        raise Exception.new("Unknown instruction: #{action.inspect}")

      end # === case action
    end # === def print

    def to_html
      while doc.current?
        i = doc.grab_current
        to_html(i)
      end
      io.to_s
    end # === def to_html

    def to_da_html
      fin = IO::Memory.new
      doc.origin.map { |i|
        fin << "\n" if !fin.empty?
        is_first = true
        is_text  = false

        i.each { |s|
          if is_first
            case s
            when "text"
              is_text = true
              lines = i.last.split("\n")
              last_txts = lines.size
              lines.each_with_index { |t, ti|
                fin << "text" << " " << t
                if ti != (last_txts - 1)
                  fin << "\n"
                end
              }
            else
              fin << s
            end
            is_first = false
          else

            if !is_text
              fin << " " << s
            end
          end
        }
      } # === map
      fin.to_s
    end # === def to_da_html

  end # === module Printer

end # === module DA_HTML
