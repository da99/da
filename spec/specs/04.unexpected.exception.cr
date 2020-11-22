
if in_spec?
  describe("Unexpected error") {
    result = run("Unexpected error 1")

    it "outputs name of describe" do
      assert result.output =~ /Unexpected error 1/
    end

    it "outputs name of test" do
      assert result.output =~ /this is unexpected/
    end

    it "outputs name of Exception class" do
      assert result.output =~ /Exception: .+this is unexpected/
    end
  }
else
  describe("Unexpected error 1") {
    it("fails") { raise Exception.new("this is unexpected") }
  }
end
