
da\_spec.cr
===========

My personal testing library for use in Crystal.
Don't use this.


Reference
==========

```crystal

  require "da_spec"

  Describe.pattern "name of test"
  Describe.pattern /name of test/

  extend DA_SPEC

  describe "My_Class" do

    it "does something" do
      assert My_Class.name == "My_Class"
    end

    it "fails" do
      assert_raises(IndexError) do
        a = [] of Int32
        a.pop
      end
    end

  end # === describe
```
