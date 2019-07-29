
require "../src/da/Window"

describe "DA::Window" do
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
