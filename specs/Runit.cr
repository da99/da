
describe "Runit.new" do

  it "sets a default sv directory" do
    name = "service_1"
    r = DA::Runit.new(name)
    assert r.sv_dir == "/etc/sv/#{name}"
  end # === it

  it "sets a default service directory" do
    name = "service_2"
    r = DA::Runit.new(name)
    assert r.service_dir == "/var/service/#{name}"
  end # === it

  it "raises DA::Runit::Exception if name has invalid chars" do
    assert_raises(DA::Runit::Exception) {
      DA::Runit.new("invalid name")
    }
  end # === it

  it "raises DA::Runit::Exception if sv dir has invalid chars" do
    e = assert_raises(DA::Runit::Exception) {
      DA::Runit.new("my_name", sv: "/invalid sv dir")
    }
    actual = (e.message || "")["/invalid sv dir"]?
    assert actual == "/invalid sv dir"
  end # === it

  it "raises DA::Runit::Exception if service dir has invalid chars" do
    e = assert_raises(DA::Runit::Exception) {
      DA::Runit.new("my_name", sv: "/invalid service dir")
    }
    actual = (e.message || "")["/invalid service dir"]?
    assert actual == "/invalid service dir"
  end # === it

  it "adds names to specified sv dir if missing: /a/b -> /a/b/name" do
    name = "file_1"
    r = DA::Runit.new(name, sv: "/a/b")
    assert r.sv_dir == "/a/b/#{name}"
  end # === it

  it "adds names to specified service dir if missing: /a/b -> /a/b/name" do
    name = "file_1"
    r = DA::Runit.new(name, service: "/c/d")
    assert r.service_dir == "/c/d/#{name}"
  end # === it

end # === desc "Runit.new"
