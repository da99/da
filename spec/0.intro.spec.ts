

import { describe, it, assert } from "da_spec/dist/src/index";
import { DA_MESSAGE } from "../src/DA_MESSAGE";

describe("new DA_MESSAGE", function () {
  it("creates an object", function () {
    let main = new DA_MESSAGE();
    let actual = typeof main;
    assert.equal(actual, "object");
  }); // it
}); // describe
