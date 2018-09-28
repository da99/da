
module DA_HTML
  module Each_Node
    extend self

    def flatten_nodes(raw : Array(Node))
      flat = [] of Node
      raw.each { |n|
        flat << n
        flatten_nodes(n, flat)
      }
      flat
    end # === def

    def flatten_nodes(node : Node, arr : Array(Node))
      case node
      when Text
        :ignore
      when Tag
        node.children.each { |c|
          arr.push c
          flatten_nodes(c, arr)
        }
      else
        raise Exception.new("Unknown type of node: #{node.inspect}")
      end
      return arr
    end # === def

    def each(nodes : Array(DA_HTML::Node))
      flatten_nodes(nodes).each { |n| yield n }
    end # === def

  end # === module Each_Node
end # === module DA_HTML
