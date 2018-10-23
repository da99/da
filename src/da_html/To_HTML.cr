
module DA_HTML
  module To_HTML
    extend self

    def to_html(document : Deque(Node))
      to_html(IO::Memory.new, document).to_s
    end # === def

    def to_html(io, document : Deque(Node))
      io << "<!doctype html>\n" if io.empty? && document.first.tag_name == "html"
      document.each { |n| to_html(io, n) }
      io
    end # === def

    {% for x in "to_html_open_tag to_html_close_tag".split %}
       def {{x.id}}(n : Tag)
         {{x.id}}(IO::Memory.new, n).to_s
       end
    {% end %}

    def to_html_open_tag(io, n : Tag)
      io << '<' << n.tag_name
      n.attributes.each { |k, v| io << ' ' << k << '=' << v.inspect }
      io << '>'
      io
    end # === def

    def to_html_close_tag(io, n : Tag)
      if !n.void?
        io << "</#{n.tag_name}>"
      end
      io
    end # def

    def to_html(n)
      to_html(IO::Memory.new, n).to_s
    end # === def

    def to_html(io, n : Node)
      case n
      when Text
        return io if n.empty? && io.empty?
        io << n.tag_text

      when Tag
        return io if {"crystal", "script", "template"}.includes?(n.tag_name)
        to_html_open_tag(io, n)
        n.children.each { |c| to_html(io, c) }
        to_html_close_tag(io, n)
      end
      io
    end # def

  end # === module To_HTML To_HTML
end # === module DA_HTML
