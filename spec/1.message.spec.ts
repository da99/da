

import { describe, it, assert } from "da_spec/dist/src/index";
import { Da_Message } from "../src/Da_Message";

describe("Da_Message#message", function () {
  it("runs all handlers", function () {
    let msg = new Da_Message();
    let x : string[] = [];
    msg.push("push something", function () { x.push("a"); });
    msg.push("push something", function () { x.push("b"); });
    msg.message("push something");
    msg.message("push something");
    assert.equal(x.join(" "), "a b a b");
  }); // it

}); // describe
