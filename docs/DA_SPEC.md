
Reference: da\_spec
==========

```crystal

  require "da_spec"

  DA_Spec.pattern "name of test"
  DA_Spec.pattern /name of test/

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

  module DA_SPEC
    def examine(*pairs)
      # override this method to display the actual/expected
      # results when an assertion fails.
    end
  end # module
```

