
require "../src/da/Watch"

describe "Watch" do
  it "keeps running a command if given seconds" do
    w = DA::Watch.new(1, "uptime")
    actual = w.read_line
    assert (actual || "")["load average"]? == "load average"
    sleep 1
    actual = w.read_line
    assert (actual || "")["load average"]? == "load average"
  end
end # describe
