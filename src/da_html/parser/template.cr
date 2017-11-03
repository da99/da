
module DA_HTML

  module Parser

    module Template

      macro included
        def_tag template do |node|
          this_io = IO::Memory.new
          node.children.each { |x|
            self.class.new(x, this_io, file_dir).run
          }
          io << %[<script type="application/template">]
          io << DA_HTML_ESCAPE.escape(this_io.to_s)
          io << "</script>"
        end

        def_tag var do |node|
          in_tree! "template"
          text = node.children.first
          if !(node.children.size == 1 && text.is_a?(XML::Node) && text.text?)
            raise Exception.new("var tag must only text.") 
          end
          "<var>#{text.content.strip}</var>"
        end
      end # === macro included

    end # === module Template

  end # === module Parser

end # === module DA_HTML
