require "./spec_helper.cr"

describe "cli: is dev" do
  it "exits 0 if is a development machine" do
    ENV["IS_DEVELOPMENT"] = "YES"
    stat = Process.run("da", "is dev".split)
    assert stat.exit_code == 0
  end # === it

  it "exists 1 if is a non-dev machine" do
    ENV["IS_DEVELOPMENT"] = ""
    stat = Process.run("da", "is dev".split)
    assert stat.exit_code == 1
  end # === it
end # === desc "cli: is dev"
