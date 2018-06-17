
describe ".bold" do
  it "bolds the text: === {{BOLD}} ===" do
    actual = DA.bold("=== {{BOLD}} ===")
    expect = "=== #{"BOLD".colorize.mode(:bold)} ==="
    assert actual == expect
  end # === it "bolds the text: === {{BOLD}} ==="
end # === desc ".bold"

describe ".red" do

  it "uses a bold, red color" do
    actual = DA.red("=== {{RED}} ===")
    assert actual == "=== #{"RED".colorize.fore(:red).mode(:bold)} ==="
  end # === it "uses a bold, red color"

end # === desc ".red"

describe ".orange" do

  it "uses a bold, yellow color" do
    actual = DA.orange("=== {{Orange is Yellow}} ===")
    assert actual == "=== #{"Orange is Yellow".colorize.fore(:yellow).mode(:bold)} ==="
  end # === it "uses a bold, red color"

end # === desc ".red"

describe ".green" do

  it "uses a bold, green color" do
    actual = DA.green("=== {{This is Green}} ===")
    assert actual == "=== #{"This is Green".colorize.fore(:green).mode(:bold)} ==="
  end # === it "uses a bold, red color"

end # === desc ".red"
