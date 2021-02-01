import { describe, it, assert } from "../../src/DA_Spec.mjs";
import { DA_Event } from "../../src/DA_Event.mjs";
describe("DA_Event#has", function () {
    it("returns a string if message is handled", function () {
        const m = new DA_Event();
        m.on("a", function () { return "a"; });
        assert.equal(m.has("a"), "a");
    });
    it("returns null  if message is not handled", function () {
        const m = new DA_Event();
        m.on("a", function () { return "a"; });
        assert.equal(m.has("b"), null);
    });
    it("returns an \"*\" if handled by an asterisk", function () {
        const m = new DA_Event();
        m.on("a", function () { return "a"; });
        m.on("*", function () { return "a"; });
        assert.equal(m.has("a"), "*");
    });
});
