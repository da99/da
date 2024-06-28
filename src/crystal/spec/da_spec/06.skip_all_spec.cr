require "./spec_helper"

if in_spec?
  describe "DA_Spec.skill_all!" do
    it "does not run any further tests" do
      original = DA_Spec.pattern
      DA_Spec.skip_all!
      describe "a failing test" do
        it("fails") { assert false == true }
      end
      DA_Spec.pattern original
      assert true == true
    end # === it "does not run any further tests"
  end # === desc "DA_Spec.skill_all!"
end
