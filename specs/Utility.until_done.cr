
describe "Utility.until_done" do
  it "runs until same" do
    actual = DA.until_done(0) { |x|
      (x >= 5) ?  x : (x+1)
    }
    assert actual == 5
  end # === it

  it "raises error it max is reached" do
    err = assert_raises(DA::Exception) {
      actual = DA.until_done(0, 10) { |x| (x >= 20) ?  x : (x+1) }
    }
    actual = (err.message || "")
    assert actual == "until_done: Reached max of 10."
  end # === it
end # === desc "Utility.until_done"
