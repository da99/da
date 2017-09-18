
class HTML
  struct Class_
    @val : String
    getter :name, :val

    def initialize(@val)
      @name = :class
    end # === def initialize(@val)

    module Attr

      def class_(s : String)
        @doc << " class=\"" << s << "\""
        self
      end # === def href_

      def class_(s)
        class_ s
        close do
          with(self) yield
        end
      end # === def href_

    end # === module Markup
  end # === struct Class_
end # === class HTML
