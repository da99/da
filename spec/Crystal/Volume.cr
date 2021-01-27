
require "../src/da/Volume"

describe "DA.volume_master" do
  it "gets volume as Int32: .num" do
    v = DA.volume_master
    assert (v.num > 0) == true
  end

  it "gets volume status: .status" do
    v = DA.volume_master
    assert({"on", "off"}.includes?(v.status) == true)
  end

  it "returns true for .on? if status == on" do
    v = DA.volume_master
    if v.status == "on"
      assert( v.on? == true )
    else
      assert( v.on? == false )
    end
  end
end # describe
