require "file_utils"

def run(raw : String)
  DA_Process.success!(raw, output: Process::Redirect::Close)
end

def new_repo
  name = "da_dev_git_specs"
  Dir.cd("/tmp") {
    FileUtils.rm_rf(name) if Dir.exists?(name)
    Dir.mkdir_p name
    Dir.cd(name) {
      run("git init")
      File.write(".gitignore", "/tmp/")
      run("git add .gitignore")
      run("git commit -m Init")
      yield
    }
    FileUtils.rm_rf(name) if Dir.exists?(name)
  }
end

describe "Files.load_changes" do
  it "works" do
    new_repo {
      DA_Dev::Git::Files.load_changes
      assert true == true
    }
  end # === it "works"
end # === desc "DA_Dev::Git::Files.load_changes"

describe "Files.changed?" do
  it "returns a Boolean" do
    new_repo {
      DA_Dev::Git::Files.load_changes
      DA_Process.success! "touch .gitignore"
      actual = DA_Dev::Git::Files.changed?(".gitignore")
      assert actual == true
    }
  end # === it "returns a Boolean"

  it "returns false if file has not been changed" do
    new_repo {
      DA_Dev::Git::Files.update_log
      actual = DA_Dev::Git::Files.changed?(".gitignore")
      assert actual == false
    }
  end # === it "returns false if file has not been changed"
end # === desc "DA_Dev::Git::Files.changed?"

describe "Files.update_log" do
  it "works" do
    new_repo {
      DA_Dev::Git::Files.update_log
      assert DA_Dev::Git::Files.changed.empty? == true
    }
  end # === it "works"
end # === desc "DA_Dev::Git::Files.update_log"
