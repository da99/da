
module DA_HTML
  module To_HTML
    extend self

    def to_html(document)
      to_html(IO::Memory.new, document).to_s
    end # === def

    def to_html(io, document)
      io << "<!doctype html>\n" if io.empty? && document.children.first.tag_name == "html"
      document.children.each { |n| to_html(io, n) }
      io
    end # === def

    def to_html_open_tag(io, n : Tag)
      io << '<' << n.tag_name
      n.attributes.each { |k, v| io << ' ' << k << '=' << v.inspect }
      io << '>'
      io
    end # === def

    def to_html_close_tag(io, n : Tag)
      case n.tag_name
      when "input"
        :ignore
      else
        io << "</#{n.tag_name}>"
      end
      io
    end # def

    def to_html(io, n : Node)
      case n
      when Text
        io << n.tag_text unless n.empty?
      when Tag
        case n.tag_name
        when "crystal", "script", "template"
          return io
        end

        to_html_open_tag(io, n)
        n.children.each { |c| to_html(io, c) }
        to_html_close_tag(io, n)
      end
      io
    end # def

  end # === module To_HTML To_HTML
end # === module DA_HTML
