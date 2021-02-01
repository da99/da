import { describe, it, assert } from "../../src/DA_Spec.mjs";
import { DA_Event } from "../../src/DA_Event.mjs";
describe("DA_Event#push", function () {
    it("adds a handler for a message", function () {
        let msg = new DA_Event();
        let x = 0;
        msg.on("increase", function () { x++; });
        msg.emit("increase");
        msg.emit("increase");
        assert.equal(x, 2);
    });
});
