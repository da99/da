
module DA_HTML
  struct To_HTML

    getter document : Document
    def initialize(@document)
    end # def

    def io
      document.html_io
    end

    def to_html
      if io.empty?
        io << "<!doctype html>\n"
        document.nodes.each { |n| print(n) }
      end

      io.to_s
    end # === def

    def print(n : Tag | Text)
      case n
      when Text
        io << n.tag_text unless n.empty?
      when Tag
        case n.tag_name
        when "crystal", "script", "template"
          return self
        end

        io << "<#{n.tag_name}"
        n.attributes.each { |k, v|
          io << ' ' << k << '=' << v.inspect
        }
        io << '>'
        n.children.each { |c| print(c) }
        io << "</#{n.tag_name}>" if n.end_tag?
      end
      self
    end # def

  end # === struct To_HTML
end # === module DA_HTML
