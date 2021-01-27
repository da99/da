import { describe, it, assert } from "da_spec/dist/src/index.mjs";
import { Da_Message } from "../src/Da_Message.mjs";
describe("Da_Message#push", function () {
    it("adds a handler for a message", function () {
        let msg = new Da_Message();
        let x = 0;
        msg.push("increase", function () { x++; });
        msg.message("increase");
        msg.message("increase");
        assert.equal(x, 2);
    });
});
