

class HTML

  module Class_Methods

    def to_html
      h = HTML.new
      with h yield
      h.to_html
    end # === def to_html

  end # === module Class_Methods

  extend Class_Methods

  def initialize
    @str = ""
  end # === def initialize

  def span(*args)
    Span.new(self)
  end # === def span

  def to_html
    @str
  end # === def to_html

  def push(s : String)
    @str += s
    self
  end

end # === class HTML


struct Attr_Id
  @val : String
  getter :name, :val
  def initialize(@val)
    @name = :id
  end

  module Method

    def id_(s)
      self.attr(Attr_Id.new(s))
      self
    end # === def href_

  end # === module Method
end

struct Attr_Class
  @val : String
  getter :name, :val
  def initialize(@val)
    @name = :class
  end # === def initialize(@val)

  module Method

    def class_(s)
      self.attr(Attr_Class.new(s))
      self
    end # === def href_

  end # === module Method
end

struct Attr_Href

  @val : String
  getter :name, :val

  def initialize(@val)
    @name = :href
  end # === def initialize(@val)

  module Method

    def href_(s)
      self.attr(Attr_Href.new(s))
      self
    end # === def href_

  end # === module Method
end


class Span

  include Attr_Id::Method
  include Attr_Class::Method

  def initialize(@target : HTML)
    @attrs = [] of Attr_Class | Attr_Id
    @body = ""
  end # === def initialize

  def attr(attr)
    @attrs.push(attr)
  end # === def attr

  def close(s : String)
    @body = s
    @target.push(to_html)
    @target
  end # === def close

  def to_html
    h = "<span"
    @attrs.each do |x|
      h +=( " " + x.name.to_s + "=\"" + x.val + "\"" )
    end
    h += ">#{@body}</span>"
    h
  end # === def to_html

end # === class Span

