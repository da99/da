
describe "DA.sections" do
  it "groups the sections based on the pattern" do
    string = "
      # -- CONDITION: --
      a
      # -- RUN: --
      b
      # -- ALWAYS: --
      c
    "
    groups = DA.sections(string, /^\s*\#\s+\-\-\s+([^:]+):\s+\-\-/m)

    assert groups == {"CONDITION" => "a", "RUN" => "b", "ALWAYS" => "c"}
  end # === it
end # === desc "DA.file_sections"
