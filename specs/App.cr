
describe "App.current!" do
  it "creates a symbolic link: current" do
    release_id = "#{Time.now.epoch}-abc1234"
    reset_file_system {
      Dir.mkdir_p "app2"
      Dir.mkdir_p "app2/#{release_id}"
      Dir.mkdir_p "app2/#{Time.now.epoch - 100}-dbc1234"
      app = DA::App.new("app2")
      app.current!
      assert `realpath #{app.current}` == `realpath app2/#{release_id}`
    }
  end # === it "creates a symbolic link: current"
end # === desc "App.current!"
