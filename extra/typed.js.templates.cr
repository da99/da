

class Page

  def initialize
  end # === def initialize

  def title
    "the title"
  end

  def records
    [Record.new("n1", "v1"), Record.new("n2", "v2"),
    Record.new("n1", "v1"), Record.new("n2", "v2")]
  end

end # === class Page

class Record

  # getter name : String
  getter val  : String

  def _id
    self.class.to_s
  end

  def initialize(@name : String, @val)
  end # === def initialize

  def names
    ["a", "b"]
  end

end # === class Record


module Base
  def div
    @io << "<div>"
    @io.<<(with self yield)
    @io << "</div>"
  end

  def title
    @io << "\n<title>"
    @io.<<(with self yield)
    @io << "</title>"
  end # === def title

  def print
    puts @io.to_s
  end
end # === module Base


module Template_Macro

  MACRO_RECORD = [] of _
  MACRO_RECORD_LOOKUP = {} of String => _

  macro render(o, &blok)
    {% Template_Macro.constant(:MACRO_RECORD) << o.stringify %}
    %t = Template.new
    %t.render {
      {{blok.body}}
    }
    %t.print
  end

  macro var(name)
    {% first_name = name.stringify.split(".").first.id %}
    if {{first_name}}
      {{name}}
    end
    "\{\{{{name}}}}"
  end

  macro each(name, &blok)
    {% first_var  = blok.args.first.id %}
    {% first_name  = name.stringify.split(".").first.id %}
    {% Template_Macro::MACRO_RECORD.push "#{name} { |#{first_var}|" %}
    raw "\n\{\{ {{name}} AS={{blok.args.first.id}} }}\n  "
    {{first_var}} = nil
    if {{first_name}}
      {{name}}.each {{blok}}
    end
    {{blok.body}}
    raw "\n\{\{/ {{name}} {{first_var}} }}"
    {% Template_Macro::MACRO_RECORD.push "} #{blok.args.first.id}" %}
  end

end # === module Template_Macro


class Template
  include Base
  @io = IO::Memory.new

  getter target : Page?

  def initialize(@target)
  end # === def initialize

  def raw(s)
    @io << s
  end

  def render
    with self yield @target
    puts @io.to_s
  end # === def render

end # === class Template

puts "========================="

alias T = Template_Macro
t = Template.new(Page.new).render { |x|
  title { T.var(x.title) }
  T.each(x.records) { |o|
    div { T.var(o._id) }
    T.each(o.names) { |n|
      div { T.var(n.downcase) }
    }
  }
  # T.each(x.records) { |y|
  #   div { T.var(y.name) }
  #   T.each(y.names) { |z|
  #     div { T.var(z.downcase) }
  #   }
  # }
}


# {% for x in Template_Macro::MACRO_RECORD %}
#   {% puts x %}
# {% end %}
