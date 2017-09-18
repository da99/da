
class HTML

  struct HREF_

    @val : String
    getter :name, :val

    def initialize(@val)
      @name = :href
    end # === def initialize(@val)

    module Attr

      def href_(s : String)
        @doc << " href=\"" << s << "\""
        self
      end # === def href_

      def href_(s : String)
        href_(s)
        close do
          with(self) yield
        end
      end # === def href_

    end # === module Attr
  end


end # === class HTML
