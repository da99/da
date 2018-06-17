
describe "Release.list" do
  it "returns an Array(String)" do
    dirs = [
      "app1/#{Time.now.epoch}-ced0de5",
      "app1/#{Time.now.epoch - 5}-bed0de5",
      "app1/#{Time.now.epoch - 10}-aed0de5"
    ]
    reset_file_system {
      dirs.each { |d| Dir.mkdir_p d }
    }
    actual = DA::Release.list(DA::App.new("app1"))
    expected = dirs.sort.map { |d| File.join("/tmp/specs_deploy", d) }
    assert(actual == expected)
  end # === it "returns an Array(String)"
end # === desc "Release"
