
if in_spec?
  describe "IT context" do

    it "has full_name set to: describe + \" \" + it" do
      assert full_name == "IT context has full_name set to: describe + \" \" + it"
    end # === it

  end # === desc "IT context"
end # === if in_spec?
