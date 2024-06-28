require "./spec_helper"

if !in_spec?
  describe("Bad") {
    it("fails") {
      actual = 1
      expect = 2
      assert actual == expect
    }
  }
else
  result = run("Bad")
  describe("Bad") {
    it("exits 1 when test fails") { assert result.exit_code == 1 }

    it("shows the file:") {
      actual = result.output.lines.find { |x| x[__FILE__]? }
      expected = "  #{"8".colorize.mode(:bold)}: #{__FILE__}"
      assert actual == expected
    }

    it "shows the variable names of the values" do
      actual = result.output.lines.select { |x| x[/: [0-9]/]? }
      expect = [
        "  #{"actual".colorize.mode(:bold)}: 1",
        "  #{"expect".colorize.mode(:bold)}: 2"
      ]
      assert actual == expect
    end # === it

  } # describe
end
