
class HTML
  struct Id_

    @val : String
    getter :name, :val

    def initialize(@val)
      @name = :id
    end

    module Attr

      def id_(s : String)
        @doc << " id=\"" << s << "\""
        self
      end # === def href_

      def id_(s : String)
        id_(s)
        close do
          with(self) yield
        end
      end # === def id_

    end # === module Attr
  end # === struct Id_
end # === class HTML
