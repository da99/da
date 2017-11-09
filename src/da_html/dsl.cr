
require "./dsl/attrs/*"

module DA_HTML

  module DSL

    macro included

      {% for name in system("find #{__DIR__}/dsl/tags -maxdepth 1 -type f").split %}
         include DA_HTML::DSL::{{name.split("/").last.upcase.gsub(/.CR$/, "").id}}
      {% end %}

      getter io : DA_HTML::IO_HTML | DA_HTML::DSL::TEMPLATE::INPUT_OUTPUT = DA_HTML::IO_HTML.new

      def self.to_html
        h = new
        with h yield
        h.io.to_html
      end

      def to_html
        io.to_html
      end # === def to_html

    end # === macro included

  end # === module DSL

end # === module DA_HTML

require "./dsl/tags/*"
