
module DA_HTML

  module ID_CLASS

    # This dummy method
    # helps to allow id_class_(*args)
    # when the arguments tuple is empty.
    # Reduces the amount of conditions and boilerplate code.
    def render_id_class!
    end # === def id_class_

    def render_id_class!(*raw)
      class_ = IO::Memory.new
      raw.each_with_index { |v, i|
        if i == 0 && v["#"]?
          render_attr!("id", v.gsub(/[^a-zA-Z0-9\_]+/, ""))
          next
        end

        new_v = v.gsub(/[^a-zA-Z0-9\_\-]+/, "")
        if !class_.empty?
          class_ << " "
        end
        class_ << new_v
      }
      if !class_.empty?
        render_attr!("class", class_.to_s)
      end
    end # === def id_class_

  end # === module ID_CLASS

end # === module DA_HTML
