
import { describe, it, assert } from "../../src/DA_Spec";
import { DA_Message } from "../../src/DA_Message";

describe("ASTERISK handlers", function () {

  it("runs on every message", function () {
    let msg = new DA_Message();
    let x : (string | number)[]  = [];
    msg.push("*", function () { x.push("b"); });
    msg.push("*", function () { x.push(2); });
    msg.message("push a");
    msg.message("push b");
    assert.equal(x.join(" "), "b 2 b 2");
  });

  it("gets passed original message", function () {
    let msg = new DA_Message();
    let x : string[]  = [];
    msg.push("*", function (orig) { x.push(orig); });
    msg.push("*", function (orig) { x.push(orig); });
    msg.message("a");
    msg.message("b");
    assert.equal(x.join(" "), "a a b b");
  }); // it

}); // describe

