
import { describe, it, assert } from "../../src/DA_Spec";
import { DA } from "../../src/DA";

describe("DA.Event emit with args", function () {
  it("passes args to function handlers", function () {
    const m = new DA.Event();
    const args : any[] = [];
    m.on("args", (a, b, c) => {
      args.push(a); args.push(b); args.push(c);
    });
    m.emit("args", "a", "b", "c");

    assert.deepEqual(args, ["a", "b", "c"]);
  }); // it
}); // describe
