
describe "File_System.public_dir?" do

  it "returns false if dir is: o+r == false" do
    reset_file_system {
      DA.success! "mkdir Public"
      DA.success! "chmod o-r Public"
      assert DA.public_dir?("./Public") == false
    }
  end # === it "it raises"

  it "returns true if dir is: o+r" do
    reset_file_system {
      DA.success! "mkdir Public"
      DA.success! "chmod o+r Public"
      assert DA.public_dir?("./Public") == true
    }
  end # === it "returns true if dir is: o+r"

  it "returns false if parent directory is: o+r == false" do
    reset_file_system {
      DA.success! "mkdir -p parent/Public"
      DA.success! "chmod o-r parent"
      DA.success! "chmod o+r parent/Public"
      assert DA.public_dir?("./parent/Public") == false
    }
  end # === it "returns false if parent directory is: o+r == false"

  it "returns false if directory is: o-X == false" do
    reset_file_system {
      DA.success! "mkdir -p Public"
      DA.success! "chmod o-X Public"
      assert DA.public_dir?("./Public") == false
    }
  end # === it "returns false if directory is: o-X == false"


  it "returns false if parent directory is: o-X == false" do
    reset_file_system {
      DA.success! "mkdir -p parent/Public"
      DA.success! "chmod o+r parent"
      DA.success! "chmod o-X parent"
      DA.success! "chmod o+rX parent/Public"
      assert DA.public_dir?("./parent/Public") == false
    }
  end # === it "returns false if parent directory is: o+r == false"


end # === desc "File_System.public_dir!"
