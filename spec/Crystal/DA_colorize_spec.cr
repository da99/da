
require "./spec_helper.cr"
require "../src/da/String"

describe ".colorize :bold" do
  it "bolds the text: === {{#{"BOLD".colorize.bold}}} ===" do
    actual = DA::Color_String.colorize(:bold, "=== {{BOLD}} ===")
    expect = "=== #{"BOLD".colorize.bold} ==="
    assert actual == expect
  end # === it "bolds the text: === {{BOLD}} ==="
end # === desc ".bold"

describe ".colorize :red" do

  it "uses a bold, red color" do
    actual = DA::Color_String.colorize(:red, "=== {{RED}} ===")
    assert actual == "=== #{"RED".colorize.fore(:red).mode(:bold)} ==="
  end # === it "uses a bold, red color"

end # === desc ".red"

describe "colorize :orange" do

  it "uses a bold, yellow color" do
    actual = DA::Color_String.colorize(:orange, "=== {{Orange is Yellow}} ===")
    assert actual == "=== #{"Orange is Yellow".colorize.fore(:yellow).mode(:bold)} ==="
  end # === it "uses a bold, red color"

  it "prints BOLD{{text}}" do
    actual = DA::Color_String.colorize(:orange, "=== BOLD{{bold}} {{Orange is Yellow}} ===")
    assert actual == "=== #{"bold".colorize.mode(:bold)} #{"Orange is Yellow".colorize.fore(:yellow).mode(:bold)} ==="
  end

end # === desc ".red"

describe "colorize :green" do

  it "uses a bold, green color" do
    actual = DA::Color_String.colorize(:green, "=== {{This is Green}} ===")
    assert actual == "=== #{"This is Green".colorize.fore(:green).mode(:bold)} ==="
  end # === it "uses a bold, red color"

end # === desc ".red"

describe "strip" do
  it "removes formatting from string" do
    actual = DA::Color_String.strip("hello {{world}} BOLD{{!!!}}")
    assert actual == "hello world !!!"
  end
end # describe
