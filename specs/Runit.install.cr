
describe "Runit#install!" do

  it "copies files to service_dir" do
    reset_file_system {
      name = "test_1"
      Dir.mkdir_p "#{name}/log"
      Dir.mkdir_p "service"
      File.write("#{name}/run", "run file")
      File.write("#{name}/log/run", "log file")
      DA.system! "chmod +x #{name}/run"
      DA.system! "chmod +x #{name}/log/run"
      runit = DA::Runit.new(name, Dir.current, "#{Dir.current}/service")
      runit.install!

      assert File.exists?("service/#{name}/run") == true
      assert File.exists?("service/#{name}/log/run") == true
    }
  end # === it "copies files to service_dir"

end # === desc "Runit#install!"
