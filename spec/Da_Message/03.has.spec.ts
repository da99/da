
import { describe, it, assert } from "da_spec/dist/src/index";
import { Da_Message } from "../../src/Da_Message";

describe("Da_Message#has", function () {
  it("returns a string if message is handled", function () {
    const m = new Da_Message();
    m.push("a", function () { return "a"; });
    assert.equal(m.has("a"), "a");
  }); // it

  it("returns null  if message is not handled", function () {
    const m = new Da_Message();
    m.push("a", function () { return "a"; });
    assert.equal(m.has("b"), null);
  }); // it

  it("returns an \"*\" if handled by an asterisk", function () {
    const m = new Da_Message();
    m.push("a", function () { return "a"; });
    m.push("*", function () { return "a"; });
    assert.equal(m.has("a"), "*");
  }); // it
}); // describe
