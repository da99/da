
require "../src/da/Bluetooth"

describe "DA::Bluetooth.connected_names" do
  it "returns an Array of connected devices by name" do
    assert DA::Bluetooth.connected_names.class == Array(String)
  end
end # describe
