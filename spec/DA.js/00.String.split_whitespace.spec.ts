
import { describe, it, assert } from "../../src/DA_Spec";
import { DA } from "../../src/DA";

describe("DA.split_whitespace", function () {
  it("removes whitespace from beginning, middle, and end", function () {
    const str = "  a  \r\n \t b    c ";
    const actual = DA.split_whitespace(str);
    assert.deepEqual(actual, "a b c".split(" "));
  }); // it
}); // describe
