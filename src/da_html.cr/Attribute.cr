
struct DA_HTML::Attribute

  class Invalid_Value < Exception
  end # class

  def self.id_class(raw : String)
    in_id   = false
    attrs   = Deque(Attribute).new
    id      = Deque(Char).new
    class_  = Deque(Char).new

    raw.each_char { |c|
      case c
      when '#'
        in_id = true
      when '.'
        in_id = false
        (class_ << ' ') unless class_.empty?
      else
        (in_id ? id : class_) << c
      end
    }

    if !id.empty?
      attrs << Attribute.new(:id, id.join)
    end

    if !class_.empty?
      attrs << Attribute.new(:class, class_.join)
    end

    attrs
  end # def

  getter name : Symbol
  getter value : String?

  def initialize(@name)
    @value = nil
  end

  def initialize(@name, @value : String)
  end

  def value?
    !@value.nil?
  end
end # === module DA_HTML::Attribute
