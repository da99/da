import { describe, it, assert } from "../../src/DA_Spec.mjs";
import { DA_Event } from "../../src/DA_Event.mjs";
describe("ASTERISK handlers", function () {
    it("runs on every message", function () {
        let msg = new DA_Event();
        let x = [];
        msg.on("*", function () { x.push("b"); });
        msg.on("*", function () { x.push(2); });
        msg.emit("push a");
        msg.emit("push b");
        assert.equal(x.join(" "), "b 2 b 2");
    });
    it("gets passed original message", function () {
        let msg = new DA_Event();
        let x = [];
        msg.on("*", function (orig) { x.push(orig); });
        msg.on("*", function (orig) { x.push(orig); });
        msg.emit("a");
        msg.emit("b");
        assert.equal(x.join(" "), "a a b b");
    });
});
