
if !in_spec?
  describe("Bad") { it("fails") { assert 1 == 2 } }
else
  result = run("Bad")
  describe("Bad") {
    it("exits 1 when test fails") { assert result.exit_code == 1 }

    it("shows the file:") {
      actual = result.output.lines.find { |x| x[__FILE__]? }
      expected = "  #{"3".colorize.mode(:bold)}: #{__FILE__}"
      assert actual == expected
    }

  } # describe
end
