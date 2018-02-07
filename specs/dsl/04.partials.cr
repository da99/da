
class My_Partial_04

  include DA_HTML::Base

  def my_block
    open_and_close_tag("div", ".my_block") {
      with self yield
    }
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
end # === desc "Partials"
