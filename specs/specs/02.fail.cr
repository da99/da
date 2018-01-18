
if in_spec?
  result = run("Bad")
  describe("Bad") {
    it "exits 1 when test fails" do
      assert result.exit_code == 1
    end
  }
else
  describe("Bad") {
    it("fails") {
      assert 1 == 2
    }
  } # === desc "Bad"
end
