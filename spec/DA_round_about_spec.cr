
require "./spec_helper.cr"
require "../src/da/Enumerable"

describe "DA.round_about"  do

  it "accepts a proc to find starting point" do
    actual = DA.round_about([0,1,2,3,4,5], ->(x : Int32) { x == 3 }) { |y|
      y == 5
    }
    assert actual == 5
  end

  it "starts from beginning if target was not found" do
    actual = DA.round_about([0,1,2,3,4,5], ->(x : Int32) { x == "a" }) { |y|
      y == 1
    }
    assert actual == 1
  end

  it "does not compare the starting point" do
    actual = DA.round_about([0,1,2,3,4,5], ->(x : Int32) { x == 3 }) { |y|
      y == 3
    }
    assert actual == nil
  end

  it "continues up to starting point" do
    actual = DA.round_about([0,1,2,3,4,5], ->(x : Int32) { x == 3 }) { |y|
      y == 2
    }
    assert actual == 2
  end
end # describe
