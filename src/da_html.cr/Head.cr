
#  These are helper methods for the
#  <head></head> section.
module DA_HTML::Head
    {% for x in "name content".split.map(&.id) %}
      def {{x}}(s : String)
        DA_HTML::Attribute.new(:{{x}}, s)
      end # def
    {% end %}

    def meta_utf8
      tag(
        :meta,
        DA_HTML::Attribute.new(:"http-equiv", "Content-Type"),
        content("text/html; charset=UTF-8")
      )
    end # def

    def title(s : String)
      tag(:title) { text s }
    end # def

    def description(s : String)
      tag(:meta, name("description"), content(s))
    end

    def author(s : String)
      tag(:meta, name("author"), content(s))
    end # === def author

    def stylesheet(raw_url : String, *attrs)
      tag(:link, rel("stylesheet"), local_href(raw_url), *attrs)
    end # === def stylesheet
end # === module DA_HTML::Head
