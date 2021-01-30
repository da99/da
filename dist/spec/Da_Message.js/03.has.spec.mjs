import { describe, it, assert } from "../../src/DA_Spec.mjs";
import { Da_Message } from "../../src/Da_Message.mjs";
describe("Da_Message#has", function () {
    it("returns a string if message is handled", function () {
        const m = new Da_Message();
        m.push("a", function () { return "a"; });
        assert.equal(m.has("a"), "a");
    });
    it("returns null  if message is not handled", function () {
        const m = new Da_Message();
        m.push("a", function () { return "a"; });
        assert.equal(m.has("b"), null);
    });
    it("returns an \"*\" if handled by an asterisk", function () {
        const m = new Da_Message();
        m.push("a", function () { return "a"; });
        m.push("*", function () { return "a"; });
        assert.equal(m.has("a"), "*");
    });
});
