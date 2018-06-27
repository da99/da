
describe "DA.human_time" do

  it "handles past time: 1 hr. ago" do
    actual = DA.human_time(Time.now - 1.hour)
    assert actual == "1 hr. ago"
  end # === it

  it "handles future time: in 1 hr." do
    actual = DA.human_time(Time.now + 1.hour)
    assert actual == "in 1 hr."
  end # === it

  it "handles future time in seconds: in 35 secs." do
    actual = DA.human_time(Time.now + 36.seconds)
    assert actual == "in 35 secs."
  end # === it

end # === desc "DA.human_time"
