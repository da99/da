
require "../spec_helper.cr"
describe "da git status" do

  before { `mkdir -p #{Spec_Git.dir}; cd #{Spec_Git.dir}; git init` }
  after { `rm -rf #{Spec_Git.dir}` }

  test "ends in exit status code 0" do
    Dir.cd(Spec_Git.dir) {
      stat = Process.run(Spec_Git.da_bin, "git status".split)
      assert(stat.exit_code == 0)
    }
  end

  test "outputs: git status" do
    Dir.cd(Spec_Git.dir) {
      io = IO::Memory.new
      stat = Process.run(Spec_Git.da_bin, "git status".split, output: io)
      io.rewind
      assert(io.to_s["nothing to commit (create/copy files and use \"git add\" to track)"]?)
    }
  end
end # describe
