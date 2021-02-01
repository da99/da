

import { describe, it, assert } from "../../src/DA_Spec";
import { DA_Event } from "../../src/DA_Event";

describe("DA_Event#message", function () {
  it("runs all handlers", function () {
    let msg = new DA_Event();
    let x : (string | number)[]  = [];
    msg.on("push something", function () { x.push("a"); });
    msg.on("push something", function () { x.push(1); });
    msg.emit("push something");
    msg.emit("push something");
    assert.equal(x.join(" "), "a 1 a 1");
  }); // it

  it("does not run handlers when they do not match", function () {
    let msg = new DA_Event();
    let x : (string | number)[]  = [];
    msg.on("a", function () { x.push("b"); });
    msg.on("b", function () { x.push(2); });
    msg.emit("a");
    msg.emit("c");
    assert.equal(x.join(" "), "b");
  });

}); // describe
