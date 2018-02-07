
class My_Partial_04

  include DA_HTML::Base

  def my_block
    raw! "<div"
      raw_id_class!(".my_block")
    raw! '>'
    with self yield self
    raw! "</div>"
  end

end # === class My_Partial_04

class My_Partial_04_Main

  include DA_HTML::Base

end # === class My_Partial_04

describe "Partials" do
  it "renders a partial" do
    actual = My_Partial_04_Main.to_html { |p|
      div {
      }
      My_Partial_04.to_html(p) {
        my_block { }
      }
    }

    assert strip(actual) == strip(%{<div></div><div class="my_block"></div>})
  end # === it "renders a partial"

  it "does a nil when :to_html is used with a block" do
    actual = :none
    My_Partial_04_Main.to_html { |p|
      div {
      }
      actual = My_Partial_04.to_html(p) {
        my_block { }
      }
    }
    assert actual == nil
  end # === it "does a nil when :to_html is used with a block"

end # === desc "Partials"
