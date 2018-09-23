
module DA_HTML
  class Document

    def self.walk(t)
      yield t
      if t.is_a?(Tag)
        t.children.each { |c|
          walk(c)
        }
      end
    end # === def

    getter raw  : String
    getter nodes = [] of Node
    getter parser  : Myhtml::Parser

    getter js_io   = IO::Memory.new
    getter cr_io   = IO::Memory.new
    getter html_io = IO::Memory.new

    def initialize(raw : String)
      @raw = DA_HTML.close_custom_tags(raw)
      @parser = Myhtml::Parser.new(@raw)
      nodes.push DA_HTML.to_tag(@parser.root!, parent: nil, index: 0)
    end # === def

    def map_walk!(&blok : Node -> Node | Nil)
      new_nodes = [] of Node
      nodes.each { |t|
        result = t.map_walk! { |t2| blok.call(t2) }
        case
        when result.is_a?(Tag) || result.is_a?(Text)
          new_nodes.push result
        when result == :remove
          nil
        end
      }
      @nodes = new_nodes
    end

    def html
      To_HTML.new(self).to_html
    end # === def

    def javascript
      To_JS.new(self).to_js
    end

    def crystal
      To_JS.new(self).to_crystal
    end

  end # === struct Document
end # === module DA_HTML
