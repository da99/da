
if in_spec?
  result = run("Describe_Header")
  describe("Describe_Header") {
    it "prints the header once" do
      assert result.output.scan("Describe_Header").size == 1
    end # === it "prints the header once"
  }
else
  describe("Describe_Header:") {
    it "passes 1" do
      assert 1 == 1
    end

    it "passes 2" do
      assert 2 == 2
    end
  }
end
