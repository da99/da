
module DA_HTML

  # Example:
  #   Walk.walk(io, document.children)
  #   io.open_tag(node) -> node || nil
  #   io.close_tag(node)
  #   io.node(node)
  module Walk
    extend self

    def walk(io, children : Array(Node))
      children.each { |node| walk(io, node) }
      io
    end

    def walk(io, node)
      case node
      when Tag
        result = io.open_tag(node)
        case result
        when Tag
          walk(io, result.children)
          io.close_tag(result)
        end
      else
        io.node(node)
      end
      io
    end # def

  end # === module Walk
end # === module DA_HTML
