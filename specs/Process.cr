
describe "Process.exit!" do
  it "raises DA:Exit with Int32, String" do
    assert_raises(DA::Exit) {
      DA.exit! 3, "My mesage"
    }
  end # === it "raises DA:Exit with Int32, String"
end # === desc "Process.exit!"
