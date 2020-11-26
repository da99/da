require "./spec_helper"

if in_spec?
  describe "Quotation Marks" do
    it("allows quotation marks in values") {
      results = run("Quotation Marks")
      assert results.exit_code == 0
    }
  end
else
  describe("Quotation Marks") {
    it "allows <" { assert "<" == "<" }
    it "allows >" { assert ">" == ">" }
    it "allows '" { assert "'" == "'" }
    it "allows \"" { assert "\"" == "\"" }
  }
end
