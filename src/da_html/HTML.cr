
module DA_HTML
  module HTML
    extend self

    def known_tag?(t : Tag)
      known_tag? t.tag_name
    end

    def known_tag?(s : String)
      case
      when "html", "link", "meta", "base,", "style", "title",
        "body", "address", "article", "aside", "footer", "header",
        "h1", "h2", "h3", "h4", "h5", "h6",
        "hgroup", "nav", "section", "blockquote",
        "dd", "dir", "div", "dl", "dt", "figcaption", "figure",
        "hr", "li", "main", "ol", "p", "pre", "ul", "a", "abbr",
        "b", "bdi", "bdo", "br", "cite", "code", "data",
        "dfn", "em", "i", "kbd", "mark", "q", "rb", "rp",
        "rt", "rtc", "ruby", "s", "samp",
        "small", "span", "strong", "sub", "sup", "time", "tt",
        "u", "var", "wbr",
        "noscript", "script",
        "del", "ins", "caption",
        "col", "colgroup", "table", "tbody", "td",
        "tfoot", "th", "thead", "tr", "button",
        "datalist", "fieldset", "form", "input",
        "label", "legend", "meter", "optgroup", "option",
        "output", "progress", "select", "textarea", "details",
        "dialog", "menu", "menuitem", "summary"

        true
      else
        false
      end
    end

    def to_html(document : Deque(Node))
      to_html(IO::Memory.new, document).to_s
    end # === def

    def to_html(io, document : Deque(Node))
      io << "<!doctype html>\n" if io.empty? && document.first.tag_name == "html"
      document.each { |n| to_html(io, n) }
      io
    end # === def

    {% for x in "open_tag close_tag".split %}
       def {{x.id}}(n : Tag)
         {{x.id}}(IO::Memory.new, n).to_s
       end
    {% end %}

    def open_tag(io, n : Tag)
      io << '<' << n.tag_name
      n.attributes.each { |k, v| io << ' ' << k << '=' << v.inspect }
      io << '>'
      io
    end # === def

    def close_tag(io, n : Tag)
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
        open_tag(io, n)
        n.children.each { |c| to_html(io, c) }
        close_tag(io, n)
      end
      io
    end # def

  end # === module HTML
end # === module DA_HTML
