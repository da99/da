require "file_utils"

def reset_repo(name : String = "git_specs")
  reset_file_system {
    Dir.mkdir_p name
    Dir.cd(name) {
      DA.success!("git init")
      File.write(".gitignore", "/tmp/")
      DA.success!("git add .gitignore")
      DA.success!("git commit -m Init")
      yield
    }
  } # reset_file_system
end


describe "Git.clean?" do
  it "returns true if no new files" do
    reset_repo {
      assert DA::Git.clean? == true
    }
  end # === it "returns true is no new files"

  it "returns false if new file" do
    reset_repo {
      DA.success! "touch a"
      assert DA::Git.clean? == false
    }
  end # === it "returns false if new file"

  it "returns false if ahead of origin" do
    reset_repo("origin_repo") {
      Dir.cd(File.expand_path "..") {
        DA.success! "git clone origin_repo new_repo"
        Dir.cd "new_repo"
        DA.success! "touch a"
        DA.success! "git add a"
        DA.success! "git commit -m new_file"
        assert DA::Git.clean? == false
      }
    }
  end # === it "returns false if ahead of origin"
end # === desc ".clean?"
