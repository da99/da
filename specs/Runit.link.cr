
describe "Runit#link!" do

  it "creates a link to the original dir" do
    reset_file_system {
      name = "new_link"
      dir  = Dir.current
      Dir.mkdir_p "sv/#{name}"
      Dir.mkdir_p "service"
      runit = DA::Runit.new(name, "#{dir}/sv", "#{dir}/service")
      runit.link!
      assert File.symlink?("#{dir}/service/#{name}") == true
      assert File.real_path("#{dir}/service/#{name}") == "#{dir}/sv/#{name}"
    }
  end # === it "creates a link to the original dir"

end # === desc "Runit#link!"
