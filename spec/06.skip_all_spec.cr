require "./spec_helper"

if in_spec?
  describe "DA_SPEC.skill_all!" do
    it "does not run any further tests" do
      original = DA_SPEC.pattern
      DA_SPEC.skip_all!
      describe "a failing test" do
        it("fails") { assert false == true }
      end
      DA_SPEC.pattern original
      assert true == true
    end # === it "does not run any further tests"
  end # === desc "DA_SPEC.skill_all!"
end
