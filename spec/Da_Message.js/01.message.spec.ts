

import { describe, it, assert } from "../../src/DA_Spec";
import { DA_Message } from "../../src/DA_Message";

describe("DA_Message#message", function () {
  it("runs all handlers", function () {
    let msg = new DA_Message();
    let x : (string | number)[]  = [];
    msg.push("push something", function () { x.push("a"); });
    msg.push("push something", function () { x.push(1); });
    msg.message("push something");
    msg.message("push something");
    assert.equal(x.join(" "), "a 1 a 1");
  }); // it

  it("does not run handlers when they do not match", function () {
    let msg = new DA_Message();
    let x : (string | number)[]  = [];
    msg.push("a", function () { x.push("b"); });
    msg.push("b", function () { x.push(2); });
    msg.message("a");
    msg.message("c");
    assert.equal(x.join(" "), "b");
  });

}); // describe
