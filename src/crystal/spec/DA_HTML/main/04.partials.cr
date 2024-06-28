
module My_Partial_04

  def my_block
    tag :div, ".my_block" do
      result = yield
      text(result) if result.is_a?(String)
    end
  end # def

end # === class My_Partial_04

struct My_Partial_04_Main

  include DA_HTML::Base
  include My_Partial_04

  def self.to_html
    page = new
    with page yield
    page.io.to_s
  end # def

end # === class My_Partial_04

describe "partials as Modules" do

  it "renders content from included module" do
    actual = My_Partial_04_Main.to_html {
      my_block { "yo yo" }
    }
    assert actual == %[<div class="my_block">yo yo</div>]
  end # === it

end # === desc "Partials"
