
module DA_HTML

  module DSL

    module ID_CLASS

      # This dummy method
      # helps to allow id_class_(*args)
      # when the arguments tuple is empty.
      # Reduces the amount of conditions and boilerplate code.
      def write_attr_id_class
      end # === def id_class_

      def write_attr_id(raw : String)
        s = raw.gsub(/[^a-zA-Z0-9\_]+/, "")
        return if s.empty?
        write_attr("id", s)
      end # === def write_attr_id

      def write_attr_id_class(*raw)
        class_ = IO::Memory.new
        raw.each_with_index { |v, i|
          if i == 0 && v["#"]?
            write_attr_id(v)
            next
          end

          new_v = v.gsub(/[^a-zA-Z0-9\_\-]+/, "")
          if !class_.empty?
            class_ << " "
          end
          class_ << new_v
        }
        if !class_.empty?
          write_attr("class", class_.to_s)
        end
      end # === def id_class_

    end # === module ID_CLASS

  end # === module DSL

end # === module DA_HTML
