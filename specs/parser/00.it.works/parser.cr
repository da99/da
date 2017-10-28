
class IT_WORKS
  include DA_HTML::Parser
  def_tags :html , :head , :title , :body , :p
  def_tag :css do |node|
    @io << %(<link href="/main.css" rel="stylesheet">)
    return false
  end
  def_tag :js do |node|
    @io << %(<script src="/main.js" type="application/javascript"></script>)
    return false
  end
end # === class Spec_Parser
