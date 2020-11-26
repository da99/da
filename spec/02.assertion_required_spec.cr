require "./spec_helper"

if !in_spec?
  describe("it") {
    it("fails if no assertion specified.") {
    }
  }
else
  describe("it") {
    it("fails if no assertion specified.") {
      result = run("it fails if no assertion specified.")
      actual = result.exit_code
      assert actual != 0
    }
  }
end # if
