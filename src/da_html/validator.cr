
module DA_HTML

  module Validator

    def attr!(page, tag_name, name, val)
      case name
      when :id, :class
        true
      else
        false
      end
    end # === def self.attr?

    def attr!(page, tag_name, name)
      case name
      when :required
        true
      else
        false
      end
    end # === def self.attr?

  end # === module Validator

  class Default_Validator
    include Validator
  end

end # === module DA_HTML
