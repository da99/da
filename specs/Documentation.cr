
require "file_utils"

def reset_docs
  dir = "tmp/out/doc"
  FileUtils.rm_rf(dir)
  Dir.mkdir_p(dir)
  yield dir
  FileUtils.rm_rf(dir)
end

describe ".compile" do

  it "bolds command name" do
    reset_docs { |dir|
      file = "#{dir}/a"
      File.write(file, "# === {{CMD}} help")
      actual = DA_Dev::Documentation.compile([file]).join
      assert actual == "\n#{"da_dev".colorize.mode(:bold)} help\n"
    }
  end # === it "bolds command name"

  it "continues rendering lines below command" do
    reset_docs { |dir|
      file = "#{dir}/a"
      File.write(file, "# === {{CMD}} help\n# === a\n# === b c")
      actual = DA_Dev::Documentation.compile([file]).join
      assert actual == "\n#{"da_dev".colorize.mode(:bold)} helpab c\n"
    }
  end # === it "continues rendering lines below command"

  it "ignores lines between comment blocks" do
    reset_docs { |dir|
      file = "#{dir}/a"
      File.write(
        file, "
         # === {{CMD}} help
         # === a
         this is ignores
         # === {{CMD}} show
         # === b
        "
      )
      actual = DA_Dev::Documentation.compile([file])
      assert actual[1] == "#{"da_dev".colorize.mode(:bold)} help"
      assert actual[2]? == "a"
      assert actual[3]? == "#{"da_dev".colorize.mode(:bold)} show"
      assert actual[4]? == "b"
    }
  end # === it "ignores lines between comment blocks"

  it "ignores a comment block if it does not contain: {{" do
    reset_docs { |dir|
      file = "#{dir}/a"
      File.write(
        file, "
         # === {{CMD}} help
         # === a
         this is ignores
         # === b
        "
      )
      actual = DA_Dev::Documentation.compile([file])
      assert actual[1]? == "#{"da_dev".colorize.mode(:bold)} help"
      assert actual[2]? == "a"
      assert actual[3]? == "\n"
      assert actual[4]? == nil
    }
  end # === it "ignores a comment block if it does not contain: {{"

end # === desc "compile"
