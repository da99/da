
module DA_HTML

  module ID_CLASS

    # This dummy method
    # helps to allow id_class_(*args)
    # when the arguments tuple is empty.
    # Reduces the amount of conditions and boilerplate code.
    def id_class_
    end # === def id_class_

    def id_class_(raw : String)
      pieces = raw.gsub(/[^a-zA-Z0-9\_\.\#\-]/, "_").split(".")
      first = pieces.first
      id_ = nil
      class_ = nil
      if first.is_a?(String) && first["#"]?
          io.render_attr!("id", pieces.shift.gsub(/#/, ""))
      end
      if !pieces.empty?
        io.render_attr!("class", pieces.join(" "))
      end
    end # === def id_class_

  end # === module ID_CLASS

end # === module DA_HTML
