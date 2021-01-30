import { describe, it, assert } from "../../src/DA_Spec.mjs";
import { DA_Message } from "../../src/DA_Message.mjs";
describe("DA_Message#push", function () {
    it("adds a handler for a message", function () {
        let msg = new DA_Message();
        let x = 0;
        msg.push("increase", function () { x++; });
        msg.message("increase");
        msg.message("increase");
        assert.equal(x, 2);
    });
});
