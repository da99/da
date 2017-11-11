
module DA_HTML

  module Template

    def render_template
      this_io = IO::Memory.new
      node.children.try { |childs|
        childs.each { |x|
          self.class.new(x, this_io, file_dir).run
        }
      }
      io << %[<script type="application/template">]
      io << DA_HTML_ESCAPE.escape(this_io.to_s)
      io << "</script>"
      :done
    end

    def render_var
      in_tree! "template"
      text = node.children.first
      if !(node.children.size == 1 && text.is_a?(XML::Node) && text.text?)
        raise Exception.new("var tag must only text.") 
      end
      "<var>#{text.content.strip}</var>"
    end

  end # === module Template

end # === module DA_HTML
