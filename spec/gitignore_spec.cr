
require "./spec_helper.cr"
require "../src/da/Git"
require "../src/da/Process"

GITIGNORE = ".gitignore"

describe "da gitignore" do
  it "adds an trailing newline" do
    SPEC.tmp_dir {
      `git init`
      lines = %w[ /lib/  ]
      File.write(GITIGNORE, lines.join('\n'))
      DA::Process.new([SPEC.da_bin, "gitignore"]).success!
      assert(File.read(GITIGNORE) == "/lib/\n")
    }
  end

  it "removes duplicate lines" do
    SPEC.tmp_dir {
      `git init`
      lines = %w[ /a/ /b/ /c/ /c/ /a/  ]
      File.write(GITIGNORE, lines.join('\n'))
      DA::Process.new([SPEC.da_bin, "gitignore"]).success!
      assert(File.read(GITIGNORE) == "#{lines.uniq.join '\n'}\n")
    }
  end

  it "adds to wrangler repos: /dist/" do
    SPEC.tmp_dir {
      `git init`
      `touch wrangler.toml`
      File.write(GITIGNORE, "")
      DA::Process.new([SPEC.da_bin, "gitignore"]).success!
      assert(File.read(GITIGNORE).split.includes?("/dist/") == true)
    }
  end

end # describe
