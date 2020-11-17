
require "./spec_helper.cr"
describe "da git status" do

  it "exists with status code 0" do
    SPEC.tmp_dir {
      `
        git init
        git remote add origin "ssh://github/da/da.git"
      `
      stat = Process.run(SPEC.da_bin, "git status".split)
      assert(stat.exit_code == 0)
    }
  end

  it "outputs: git status" do
    SPEC.tmp_dir {
      ` git init `
      proc = DA::Process.new([SPEC.da_bin, "git", "status"])
      assert(proc.out_err["nothing to commit (create/copy files and use \"git add\" to track)"]?)
    }
  end

  it "outputs: no remote {{origin}} specified" do
    SPEC.tmp_dir {
      ` git init `
      proc = DA::Process.new([SPEC.da_bin, "git", "status"])
      assert(proc.out_err["No remote {{origin}} specified"]?)
    }
  end
end # describe
