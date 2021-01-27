
describe "Process.exit!" do
  it "raises DA:Exit with Int32, String" do
    assert_raises(DA::Exit) {
      DA.exit! 3, "My message"
    }
  end # === it "raises DA:Exit with Int32, String"

  it "sets exit_code" do
    err = assert_raises(DA::Exit) {
      DA.exit! 3, "My Message"
    }
    if err.is_a?(DA::Exit)
      assert err.exit_code == 3
    else
      assert err.class == err.class
    end
  end # === it "sets exit_code"

  it "sets .message" do
    msg = Time.local.to_s
    err = assert_raises(DA::Exit) {
      DA.exit! 3, msg
    }
    if err.is_a?(DA::Exit)
      assert err.message == msg
    else
      assert err.class == err.class
    end
  end # === it "sets exit_code"
end # === desc "Process.exit!"

describe "Process.exec!" do
  it "can accept just a String." do
    actual = DA.out_err("tmp/out/__.run", "exit! accept just a String".split)
    assert actual["load average"]? == "load average"
  end
end
