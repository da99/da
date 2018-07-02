
describe "DA::SQL_Sections" do
  it "splits string into CONDITION,RUN,ALWAYS RUN" do
    sql = "
      -- CONDITION: -------
      SELECT 1
      -- RUN: ---
      A
      b
      c
      -- ALWAYS RUN: ----
      DO something
    "
    actual = DA::SQL_Sections.new(sql)
    assert actual.condition  == "SELECT 1"
    assert actual.run        == "A\n      b\n      c"
    assert actual.always_run == "DO something"
  end # === it

  it "raises DA::SQL::Exception if unknown section" do
    msg = assert_raises(DA::SQL::Exception) {
      DA::SQL_Sections.new("-- SOMETHING: ----\na")
    }.message || ""
    assert msg["Invalid SQL section: \"SOMETHING\""]?.is_a?(String) == true
  end # === it
end # === desc "DA.sql_sections"
