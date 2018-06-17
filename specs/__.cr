
ENV["IS_TEST"] = "yes"

require "../src/da"
require "da_spec"

extend DA_SPEC

DA.system! "mkdir -p /tmp/deploy/var/service"
DA.system! "mkdir -p /tmp/deploy/etc/sv"

describe "DA" do
  it "sets SHARDS_INSTALL_PATH" do
    path = ENV["SHARDS_INSTALL_PATH"]? || ""
    assert path[/\.shards\/\.install/]? == ".shards/.install"
  end # === it "sets SHARDS_INSTALL_PATH"

  it "sets CRYSTAL_PATH" do
    path = ENV["CRYSTAL_PATH"]? || ""
    assert path[/\.shards\/\.install/]? == ".shards/.install"
  end # === it "sets CRYSTAL_PATH"
end # === desc "DA_DEV"

require "./Colorize"
