
require "../src/da/Lemonbar"

describe "DA::Lemonbar" do
  it "runs" do
    l = DA::Lemonbar.new
    l.write("it runs")
    assert l.process.terminated? == false
    l.process.kill
    10.times { |x|
      break if l.process.terminated?
      sleep 0.1
    }
    assert l.process.terminated? == true
  end # it
end # describe
