
class HTML
  class SPAN

    include Element::Has_Content

    include Id_::Attr
    include Class_::Attr

    def tag_name
      :span
    end # === def tag_name

    def initialize(@doc : HTML)
      @doc.open_tag
      @doc << "\n<"
      @doc << tag_name.to_s
      @has_body = false
    end # === def initialize

    module Markup

      def span
        SPAN.new(self)
      end # === def span

      def span
        e = SPAN.new(self)
        e.close do
          with self yield
        end
      end # === def span

    end # === module Markup

  end # === class SPAN
end # === class HTML
