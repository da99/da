
describe "cli: is dev" do
  it "exits 0 if is a development machine" do
    stat = Process.run("da", "is dev".split)
    assert stat.exit_code == 0
  end # === it

  it "exists 1 if is a non-dev machine" do
    ENV["IS_DEVELOPMENT"] = ""
    ENV["IS_DEV"] = ""
    stat = Process.run("da", "is dev".split)
    assert stat.exit_code == 1
    ENV["IS_DEVELOPMENT"] = "yes"
    ENV["IS_DEV"] = "yes"
  end # === it
end # === desc "cli: is dev"
