
da\_spec.cr
===========

My personal testing library for use in Crystal.
Don't use this.


Reference
==========

```crystal

  require "da_spec"

  describe "My_Class" do

    it "does something" do
      assert My_Class.name == "My_Class"
    end

    it "fails" do
      assert_raises(NameError) do
        My_Class.undefined
      end
    end

  end # === describe
```
