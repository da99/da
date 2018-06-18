
da\_spec.cr
===========

My personal testing library for use in Crystal.
No one would want to use this except myself.


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
      assert_raises(IndexError) {
        a = [] of Int32
        a.pop
      } # returns the error.
    end

  end # === describe
```
