import { describe, it, assert } from "da_spec/dist/src/index.mjs";
import { Da_Message } from "../src/Da_Message.mjs";
describe("Da_Message#message", function () {
    it("runs all handlers", function () {
        let msg = new Da_Message();
        let x = [];
        msg.push("push something", function () { x.push("a"); });
        msg.push("push something", function () { x.push(1); });
        msg.message("push something");
        msg.message("push something");
        assert.equal(x.join(" "), "a 1 a 1");
    });
    it("does not run handlers when they do not match", function () {
        let msg = new Da_Message();
        let x = [];
        msg.push("a", function () { x.push("b"); });
        msg.push("b", function () { x.push(2); });
        msg.message("a");
        msg.message("c");
        assert.equal(x.join(" "), "b");
    });
});
