
module DA_HTML

  module Validator

    def attr!(page, tag_name, name, val)
      true
    end # === def self.attr?

    def attr!(page, tag_name, name)
      true
    end # === def self.attr?

  end # === module Validator

  class Default_Validator
    include Validator
  end

end # === module DA_HTML
