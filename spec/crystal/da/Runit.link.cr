
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

  it "removes a broken link" do
    reset_file_system {
      name = "broken"
      Dir.mkdir_p "sv/#{name}"
      Dir.mkdir "service"
      DA.system! "ln -s --no-dereference a service/#{name}"

      dir = Dir.current
      runit = DA::Runit.new(name, "#{dir}/sv", "#{dir}/service")

      runit.link!
      assert File.real_path("service/#{name}") == File.real_path("sv/#{name}")
    }
  end # === it

  it "does not a create another link if it already exists" do
    reset_file_system {
      name = "new_link"
      Dir.mkdir_p "sv/#{name}"
      Dir.mkdir "service"

      dir = Dir.current
      runit = DA::Runit.new(name, "#{dir}/sv", "#{dir}/service")

      runit.link!
      runit.link!
      assert File.symlink?("#{dir}/service/#{name}") == true
      assert File.symlink?("#{dir}/service/#{name}/#{name}") == false
    }
  end # === it

  it "raises DA::Runit::Exception if sv dir does not exist" do
    reset_file_system {
      name = "name_3"
      Dir.mkdir_p "service/#{name}"
      r = DA::Runit.new(name, sv: "#{Dir.current}/sv", service: "#{Dir.current}/service/#{name}")
      e = assert_raises(DA::Runit::Exception) {
        r.link!
      }
      actual = e.message || ""
      msg = "#{Dir.current}/sv/#{name}"
      assert actual[msg]? == msg
    }
  end # === it

  it "raises DA::Runit::Exception if parent service dir does not exist" do
    reset_file_system {
      name = "name_3"
      Dir.mkdir_p "sv/#{name}"
      r = DA::Runit.new(name, sv: "#{Dir.current}/sv", service: "#{Dir.current}/service/#{name}")
      e = assert_raises(DA::Runit::Exception) {
        r.link!
      }
      actual = e.message || ""
      msg = "#{Dir.current}/service"
      assert actual[msg]? == msg
    }
  end # === it

end # === desc "Runit#link!"
