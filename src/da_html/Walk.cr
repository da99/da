
module DA_HTML
  module Walk
    extend self

    def walk(printer, document : Document)
      document.nodes.each { |node|
        walk(printer, node)
      }
      printer
    end

    def walk(printer, node : Node)
      case node
      when Tag
        result = printer.print_open_tag(node)
        if result
          result.children.each { |n|
            walk(printer, n)
          }
          printer.print_close_tag(result)
        end
      else
        printer.print(node)
      end
    end

    def walk(other)
      nil
    end

  end # === module Walk
end # === module DA_HTML
