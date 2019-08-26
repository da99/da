
require "../src/da/Window"

describe "DA::Window" do
  it "turns an Int32 String into a hex string" do
    raw = "18898155"
    target = "0x01205ceb"
    assert DA::Window.clean_id(raw) == target
  end

  it "turns a 9 char hex String into a 10 hex string" do
    raw = "0x1205ceb"
    target = "0x01205ceb"
    assert DA::Window.clean_id(raw) == target
  end

  it "sets geo from Window::Geo.list" do
    DA::Window.update
    win_id = `xdotool getactivewindow`.strip
    win_geo = DA::Window.to_geo(win_id)

    geo = DA::Window::Geo.new(
      x: win_geo.x,
      y: win_geo.y,
      w: win_geo.w,
      h: win_geo.h,
      name: "Custom1"
    )

    DA::Window::Geo.list << geo
    actual = DA::Window.new(win_id)
    assert actual.geo == geo
  end

end # describe

describe "DA::Window.groups" do
  it "returns windows group by class_" do
    DA::Window.update
    actual = DA::Window.groups.keys.join(",")
    target = `wmctrl -lx | cut -d' ' -f4 | cut -d'.' -f2 | uniq`.strip.split('\n').join(',')
    assert actual == target
  end
end # describe
