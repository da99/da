
require "../src/da/Network"

describe "Network.time" do
  it "returns Unix epoch from network" do
    raw = DA::Network.time.to_s
    actual = raw[/^\d{10}$/]?
    assert actual != nil
  end
end # describe
