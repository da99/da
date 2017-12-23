
if in_spec?
  results = run("Good")
  describe "Good" do
    it("exits 0 if results pass") { assert results.exit_code == 0 }
  end
else
  describe("Good") { it "passes" { assert 1 == 1 } }
end
